/*
===============================================================================
Script Name : bronze_to_silver_erp_loc_a101.sql
Author      : Basem Torky
Purpose     : Data quality cleaning and transformation for ERP Location Data
Source      : bronze.erp_loc_a101
Target      : silver.erp_loc_a101
===============================================================================
*/

-- ============================================================================
-- Step 1: Initial Data Review
-- Check for data formatting issues and character inconsistencies
-- ============================================================================
SELECT
    REPLACE(cid, '-', '') AS cid,
    cntry
FROM bronze.erp_loc_a101;
GO


-- ============================================================================
-- Step 2: Data Standardization and Consistency
-- Review distinct country values to detect variations or non-standard entries
-- ============================================================================
SELECT DISTINCT
    cntry
FROM bronze.erp_loc_a101;
GO


-- ============================================================================
-- Step 3: Apply Data Cleaning Rules
-- - Remove hyphens from CID
-- - Standardize country names
-- - Clean whitespace, line breaks, and tab characters
-- ============================================================================
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE 
        WHEN UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(cntry)), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) = 'DE'
            THEN 'Germany'
        WHEN UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(cntry)), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) IN ('US', 'USA')
            THEN 'United States'
        WHEN UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(cntry)), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) = '' 
             OR cntry IS NULL
            THEN 'n/a'
        ELSE UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(cntry)), CHAR(13), ''), CHAR(10), ''), CHAR(9), ''))
    END AS cntry
FROM bronze.erp_loc_a101;
GO


-- ============================================================================
-- Step 4: Insert Cleaned Data into Silver Layer
-- - Ensure clean standardized country names
-- - Maintain consistent structure for downstream consumption
-- ============================================================================
INSERT INTO silver.erp_loc_a101 (cid, cntry)
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE 
        WHEN UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(cntry)), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) = 'DE'
            THEN 'Germany'
        WHEN UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(cntry)), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) IN ('US', 'USA')
            THEN 'United States'
        WHEN UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(cntry)), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) = '' 
             OR cntry IS NULL
            THEN 'n/a'
        ELSE UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(cntry)), CHAR(13), ''), CHAR(10), ''), CHAR(9), ''))
    END AS cntry
FROM bronze.erp_loc_a101;
GO


-- ============================================================================
-- Step 5: Post-Load Data Quality Checks
-- - Check nulls or non-standard country values
-- - Validate CID format consistency
-- ============================================================================
SELECT
    COUNT(*) AS total_records,
    SUM(CASE WHEN cid IS NULL OR cid = '' THEN 1 ELSE 0 END) AS null_or_blank_cid,
    SUM(CASE WHEN cntry IS NULL OR cntry = 'n/a' THEN 1 ELSE 0 END) AS invalid_country_count,
    COUNT(DISTINCT cntry) AS distinct_country_count
FROM silver.erp_loc_a101;
GO
