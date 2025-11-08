/*
===============================================================================
Script Name : bronze_to_silver_erp_cust_az12.sql
Author      : Basem Torky
Purpose     : Data quality cleaning and transformation for ERP Customer Data
Source      : bronze.erp_cust_az12
Target      : silver.erp_cust_az12
===============================================================================
*/

-- ============================================================================
-- Step 1: Review raw data
-- ============================================================================
SELECT
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12;
GO


-- ============================================================================
-- Step 2: Compare with existing silver table
-- ============================================================================
SELECT *
FROM silver.crm_cust_info;
GO


-- ============================================================================
-- Step 3: Clean CID values (remove extra 'NAS' prefix)
-- ============================================================================
SELECT
    cid,
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cleaned_cid,
    bdate,
    gen
FROM bronze.erp_cust_az12;
GO


-- ============================================================================
-- Step 4: Validate birth date values (exclude unrealistic or future dates)
-- ============================================================================
SELECT
    bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();
GO


-- ============================================================================
-- Step 5: Apply date cleaning logic
-- ============================================================================
SELECT
    cid,
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cleaned_cid,
    CASE 
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS cleaned_bdate,
    gen
FROM bronze.erp_cust_az12;
GO


-- ============================================================================
-- Step 6: Check distinct gender values for data quality
-- ============================================================================
SELECT DISTINCT
    UPPER(TRIM(gen)) AS gen_values
FROM bronze.erp_cust_az12;
GO


-- ============================================================================
-- Step 7: Clean gender values
-- ============================================================================
SELECT DISTINCT
    gen AS original_gen,
    CASE 
        WHEN UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(gen)), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) IN ('F', 'FEMALE')
            THEN 'Female'
        WHEN UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(gen)), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) IN ('M', 'MALE')
            THEN 'Male'
        ELSE 'n/a'
    END AS cleaned_gen
FROM bronze.erp_cust_az12;
GO


-- ============================================================================
-- Step 8: Combine all cleaning logic in a single transformation query
-- ============================================================================
SELECT
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,
    CASE 
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    CASE 
        WHEN UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(gen)), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) IN ('F', 'FEMALE')
            THEN 'Female'
        WHEN UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(gen)), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) IN ('M', 'MALE')
            THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;
GO


-- ============================================================================
-- Step 9: Insert cleaned data into silver layer
-- ============================================================================
INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
SELECT
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,
    CASE 
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    CASE 
        WHEN UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(gen)), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) IN ('F', 'FEMALE')
            THEN 'Female'
        WHEN UPPER(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(gen)), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) IN ('M', 'MALE')
            THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;
GO


-- ============================================================================
-- Step 10: Run post-load quality checks
-- ============================================================================
-- Check nulls, invalid genders, or out-of-range dates
SELECT 
    COUNT(*) AS total_records,
    SUM(CASE WHEN cid IS NULL THEN 1 ELSE 0 END) AS null_cid,
    SUM(CASE WHEN gen NOT IN ('Male', 'Female', 'n/a') THEN 1 ELSE 0 END) AS invalid_gender,
    SUM(CASE WHEN bdate IS NULL THEN 1 ELSE 0 END) AS null_bdate
FROM silver.erp_cust_az12;
GO
