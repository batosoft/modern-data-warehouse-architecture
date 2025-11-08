/* ==========================================================================================
   Data Cleansing & Transformation Script
   Source      : bronze.crm_sales_details
   Target      : silver.crm_sales_details
   Author      : Basem Torky
   Purpose     : Perform data quality checks and load cleansed data into the Silver Layer
   ========================================================================================== */

USE DataWarehouse;
GO

/* ==========================================================================================
   STEP 1: Data Quality Checks on Bronze Layer
   ========================================================================================== */

-- 1.1 Check for unwanted spaces in sales order numbers
SELECT 
    sls_order_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_order_num != TRIM(sls_order_num);
GO

-- 1.2 Validate product references (should exist in CRM Product table)
SELECT 
    sls_order_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);
GO

-- 1.3 Validate customer references (should exist in CRM Customer table)
SELECT 
    sls_order_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);
GO

-- 1.4 Check for invalid dates (format issues or out-of-range)
SELECT 
    NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
   OR LEN(sls_order_dt) != 8
   OR sls_order_dt > 10500101
   OR sls_order_dt < 19000101;
GO

-- 1.5 Check for invalid order date relationships
SELECT
    *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;
GO

-- 1.6 Validate sales consistency: Sales = Quantity * Price
SELECT DISTINCT
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price AS old_sls_price,
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS new_sls_sales,
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS new_sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
GO

/* ==========================================================================================
   STEP 2: Silver Layer Table Creation (Post-Cleansing Structure)
   ========================================================================================== */

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_order_num   NVARCHAR(50),
    sls_prd_key     NVARCHAR(50),
    sls_cust_id     INT,
    sls_order_dt    DATE,
    sls_ship_dt     DATE,
    sls_due_dt      DATE,
    sls_sales       INT,
    sls_quantity    INT,
    sls_price       INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

/* ==========================================================================================
   STEP 3: Data Cleansing & Insertion into Silver Layer
   ========================================================================================== */

INSERT INTO silver.crm_sales_details (
    sls_order_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT 
    sls_order_num,
    sls_prd_key,
    sls_cust_id,
    CASE 
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,
    CASE 
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,
    CASE 
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;
GO

/* ==========================================================================================
   STEP 4: Post-Load Validation
   ========================================================================================== */

-- Verify record count
SELECT COUNT(*) AS total_records_silver
FROM silver.crm_sales_details;

-- Validate that all key fields are populated
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_num IS NULL 
   OR sls_prd_key IS NULL 
   OR sls_cust_id IS NULL;

-- Check for date anomalies
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Validate Sales calculation consistency
SELECT *
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * ABS(sls_price);
GO
