-- ==========================================================
-- File: create_gold_dim_customers.sql
-- Created/Updated: 2025-11-09
-- Purpose: Create dimensional view for customers in Gold layer,
--          check duplicates, and handle gender data quality.
-- ==========================================================

-- ==========================================================
-- Optional: Rollback previous view
-- ==========================================================
DROP VIEW IF EXISTS gold.dim_customers;


-- ==========================================================
-- 1. Identify Duplicate Customer IDs
-- ==========================================================
SELECT cst_id, COUNT(*) 
FROM (
    SELECT 
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_material_status,
        ci.cst_gndr,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry
    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca
        ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 la
        ON ci.cst_key = la.cid
) t
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- ==========================================================
-- 2. Full Customer Details from CRM and ERP Sources
-- ==========================================================
SELECT 
    ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_material_status,
    ci.cst_gndr,
    ci.cst_create_date,
    ca.bdate,
    ca.gen,
    la.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;


-- ==========================================================
-- 3. Check and Fix Data Quality Issue in Gender
-- ==========================================================
SELECT 
    ci.cst_gndr,
    ca.gen,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender
        ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid
ORDER BY 1, 2;


-- ==========================================================
-- 4. Create Dimensional Customer View in Gold Layer
-- ==========================================================
CREATE OR REPLACE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    ci.cst_material_status AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the master for gender
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ci.cst_create_date AS create_date,
    ca.bdate AS birthdate,
    la.cntry AS country
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;


-- ==========================================================
-- 5. Check the Created View
-- ==========================================================
SELECT * 
FROM gold.dim_customers;
