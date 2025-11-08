/*
===============================================================================
Script Name : clean_erp_px_cat_g1v2.sql
Author      : Basem Torky
Purpose     : Data quality checks and transfer for ERP Product Category Data
Source      : bronze.erp_px_cat_g1v2
Target      : silver.erp_px_cat_g1v2
===============================================================================
*/

-- ============================================================================
-- Step 1: Initial Data Review
-- Preview the raw data from the bronze layer
-- ============================================================================
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;
GO


-- ============================================================================
-- Step 2: Check for Unwanted Leading or Trailing Spaces
-- Identify any values that require trimming for consistency
-- ============================================================================
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);
GO


-- ============================================================================
-- Step 3: Data Standardization and Consistency Checks
-- Review distinct values for each attribute to ensure consistency
-- ============================================================================
-- 3.1 Maintenance
SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;
GO

-- 3.2 Category
SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;
GO

-- 3.3 Subcategory
SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2;
GO


-- ============================================================================
-- Step 4: Insert Data into Silver Layer
-- Data passed quality checks — proceed with clean insertion
-- ============================================================================
INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
SELECT
    id,
    TRIM(cat) AS cat,
    TRIM(subcat) AS subcat,
    TRIM(maintenance) AS maintenance
FROM bronze.erp_px_cat_g1v2;
GO


-- ============================================================================
-- Step 5: Post-Load Data Quality Checks
-- Validate the successful data load and consistency of values
-- ============================================================================
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT cat) AS distinct_categories,
    COUNT(DISTINCT subcat) AS distinct_subcategories,
    COUNT(DISTINCT maintenance) AS distinct_maintenance_types
FROM silver.erp_px_cat_g1v2;
GO

-- Check for NULL or empty values after loading
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat IS NULL OR cat = ''
   OR subcat IS NULL OR subcat = ''
   OR maintenance IS NULL OR maintenance = '';
GO
