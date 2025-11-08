/******************************************************************************************
    Script Name: silver_layer_table_setup_and_load.sql
    Database: DataWarehouse
    Author: Basem Torky
    Purpose:
        - Create Silver Layer tables for CRM and ERP domains.

    Layers:
        • Silver → Cleaned and structured tables ready for analytics.

    Notes:
        - Ensure file paths exist on the SQL Server host machine
******************************************************************************************/

USE DataWarehouse;
GO

/******************************************************************************************
    1. CREATE SILVER LAYER TABLES
******************************************************************************************/

-- Drop and recreate silver.crm_cust_info
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_material_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Drop and recreate silver.crm_prd_info
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Drop and recreate silver.crm_sales_details
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
    sls_order_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Drop and recreate silver.erp_loc_a101
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Drop and recreate silver.erp_cust_az12
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Drop and recreate silver.erp_px_cat_g1v2
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/******************************************************************************************
    2. VALIDATE CREATED TABLES
******************************************************************************************/
SELECT 
    s.name AS SchemaName, 
    t.name AS TableName
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
ORDER BY SchemaName, TableName;
GO
