-- ==========================================================
-- Script: create_datawarehouse_objects.sql
-- Description: Creates the DataWarehouse database, schemas,
--              and sample bronze layer tables for CRM and ERP data.
-- Author: Basem Torky
-- Date:   2025-11-02
-- ==========================================================

-- ==========================================================
-- Step 1: Switch to DataWarehouse database
-- ==========================================================
USE DataWarehouse;
GO

-- ==========================================================
-- Step 2: Create the Data Warehouse database
-- ==========================================================
IF DB_ID('DataWarehouse') IS NOT NULL
BEGIN
    PRINT 'Database [DataWarehouse] already exists. Dropping and recreating...';
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END
GO

CREATE DATABASE DataWarehouse;
GO

-- ==========================================================
-- Step 3: Switch context to the new database
-- ==========================================================
USE DataWarehouse;
GO

-- ==========================================================
-- Step 4: Create Schemas (Bronze, Silver, Gold)
-- ==========================================================
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

-- ==========================================================
-- Step 5: Create Bronze Layer Tables
-- ==========================================================
-- These tables hold raw data ingested directly from CRM and ERP sources
-- without any transformation.

--------------------------------------------------------------
-- CRM Customer Information
--------------------------------------------------------------
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id          INT,
    cst_key         NVARCHAR(50),
    prd_nm          NVARCHAR(50),
    prd_cost        INT,
    prd_line        NVARCHAR(50),
    prd_start_dt    DATETIME,
    prd_end_dt      DATETIME
);
GO

--------------------------------------------------------------
-- CRM Product Information
--------------------------------------------------------------
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id          INT,
    prd_key         NVARCHAR(50),
    prd_nm          NVARCHAR(50),
    prd_cost        INT,
    prd_line        NVARCHAR(50),
    prd_start_dt    DATETIME,
    prd_end_dt      DATETIME
);
GO

--------------------------------------------------------------
-- CRM Sales Details
--------------------------------------------------------------
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_order_num   NVARCHAR(50),
    sls_prd_key     NVARCHAR(50),
    sls_cust_id     INT,
    sls_order_dt    DATETIME,
    sls_ship_dt     DATETIME,
    sls_due_dt      DATETIME,
    sls_sales       DECIMAL(18,2),
    sls_quantity    INT,
    sls_price       DECIMAL(18,2)
);
GO

--------------------------------------------------------------
-- ERP Location Data
--------------------------------------------------------------
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid     NVARCHAR(50),
    cntry   NVARCHAR(50)
);
GO

--------------------------------------------------------------
-- ERP Customer Data
--------------------------------------------------------------
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid     NVARCHAR(50),
    bdate   DATE,
    gen     NVARCHAR(50)
);
GO

--------------------------------------------------------------
-- ERP Product Category Data
--------------------------------------------------------------
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id              NVARCHAR(50),
    cat             NVARCHAR(50),
    subcat          NVARCHAR(50),
    maintenance     NVARCHAR(50)
);
GO

-- ==========================================================
-- Step 6: Verify Table Creation
-- ==========================================================
SELECT s.name AS SchemaName, t.name AS TableName
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
ORDER BY SchemaName, TableName;
GO
