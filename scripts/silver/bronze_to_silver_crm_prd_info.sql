/******************************************************************************************
    Script Name: bronze_to_silver_crm_prd_info.sql
    Database: DataWarehouse
    Author: Basem Torky
    Purpose:
        - Perform data validation and transformation for CRM Product Info data.
        - Clean and standardize product attributes (key, cost, line, and dates).
        - Load cleansed data into Silver layer.

    Steps:
        1. Initial Data Exploration and Key Transformation
        2. Data Quality Checks
        3. Data Cleansing and Standardization
        4. DDL Update for Silver Table
        5. Final Data Load
        6. Validation of Loaded Data
******************************************************************************************/

USE DataWarehouse;
GO

/******************************************************************************************
-- 1. INITIAL DATA EXPLORATION AND KEY TRANSFORMATION
-- Purpose: Extract category ID and refined product key from the composite prd_key field
******************************************************************************************/
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;
GO


/******************************************************************************************
-- 2. DATA QUALITY CHECKS
******************************************************************************************/

-- 2.1 Check for unwanted spaces in product name
-- Expectation: No result (no extra spaces)
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);
GO

-- 2.2 Check for NULLs or negative product costs
-- Expectation: No result (all costs positive and not null)
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;
GO

-- 2.3 Check for distinct product line codes (for mapping validation)
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;
GO

-- 2.4 Check for invalid date orders (end date < start date)
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
GO


/******************************************************************************************
-- 3. DATA CLEANSING AND STANDARDIZATION
******************************************************************************************/

-- 3.1 Replace NULL costs with 0 and clean product line values
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
         WHEN 'M' THEN 'Mountain'
         WHEN 'R' THEN 'Road'
         WHEN 'S' THEN 'Other Sales'
         WHEN 'T' THEN 'Touring'
         ELSE 'n/a'
    END AS prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info;
GO


-- 3.2 Fix date order issues using LEAD() to derive correct end date per product key
SELECT 
    prd_id,
    prd_key,
    prd_nm,
    prd_start_dt,
    prd_end_dt,
    LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');
GO

-- 3.3 Apply final transformation logic with derived end dates
SELECT
    prd_id,
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
         WHEN 'M' THEN 'Mountain'
         WHEN 'R' THEN 'Road'
         WHEN 'S' THEN 'Other Sales'
         WHEN 'T' THEN 'Touring'
         ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info;
GO


/******************************************************************************************
-- 4. DDL UPDATE FOR SILVER TABLE
-- Purpose: Adjust Silver schema to match the cleansed and standardized data model
******************************************************************************************/
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/******************************************************************************************
-- 5. FINAL TRANSFORMATION AND LOAD INTO SILVER LAYER
******************************************************************************************/
INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
         WHEN 'M' THEN 'Mountain'
         WHEN 'R' THEN 'Road'
         WHEN 'S' THEN 'Other Sales'
         WHEN 'T' THEN 'Touring'
         ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info;
GO


/******************************************************************************************
-- 6. BASIC DATA QUALITY VALIDATION AFTER LOAD
******************************************************************************************/
-- Verify record count
SELECT COUNT(*) AS RowCount
FROM silver.crm_prd_info;
GO

-- Spot-check transformed data
SELECT TOP 20 *
FROM silver.crm_prd_info;
