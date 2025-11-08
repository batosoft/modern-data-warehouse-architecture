/******************************************************************************************
    Script Name: bronze_to_silver_crm_cust_info.sql
    Database: DataWarehouse
    Purpose:
        This script performs data quality checks and transformations 
        before loading cleaned data from the Bronze layer to the Silver layer.

    Steps:
        1. Check for Nulls or Duplicates in Primary Key
        2. Check for Unwanted Spaces
        3. Check Data Standardization & Consistency
        4. Load Clean Data into Silver Layer
******************************************************************************************/

USE DataWarehouse;
GO

/******************************************************************************************
-- 1. Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result (each cst_id should be unique and non-null)
******************************************************************************************/
SELECT
    cst_id,
    COUNT(*) AS duplicate_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
GO

/******************************************************************************************
-- Diagnostic: Check how duplicates are distributed for a specific customer (example: cst_id = 29466)
******************************************************************************************/
SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id = 29466;
GO

/******************************************************************************************
-- Select only the latest record per customer (deduplication logic)
******************************************************************************************/
SELECT
    *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t
WHERE flag_last = 1;
GO

/******************************************************************************************
-- 2. Check for Unwanted Spaces in Customer Names
-- Expectation: No result (TRIM should remove leading/trailing spaces)
******************************************************************************************/
SELECT
    cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
GO

/******************************************************************************************
-- Preview Cleaned Data After Removing Extra Spaces (Latest Record per Customer)
******************************************************************************************/
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    cst_material_status,
    cst_gndr,
    cst_create_date
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t
WHERE flag_last = 1;
GO

/******************************************************************************************
-- 3. Check Data Standardization & Consistency
-- Purpose: Identify unique gender values to verify consistency
******************************************************************************************/
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;
GO

/******************************************************************************************
-- 4. Load Cleaned & Standardized Data into Silver Layer
-- Notes:
--    - Removes duplicates
--    - Trims spaces
--    - Standardizes gender and marital status codes
******************************************************************************************/
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_material_status,
    cst_gndr,
    cst_create_date
)
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE 
        WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
        WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
        ELSE 'n/a'
    END AS cst_material_status,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t
WHERE flag_last = 1;
GO

/******************************************************************************************
-- 5. Validate Final Load
******************************************************************************************/
SELECT *
FROM silver.crm_cust_info;
GO
