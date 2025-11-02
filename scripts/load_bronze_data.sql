-- ==========================================================
-- Script: load_bronze_data.sql
-- Description: Loads raw data from CRM and ERP CSV files into
--              Bronze layer tables using BULK INSERT.
-- Author: Basem Torky
-- Date:   2025-11-02
-- ==========================================================

USE DataWarehouse;
GO

-- ==========================================================
-- Load CRM Source Data
-- ==========================================================

--------------------------------------------------------------
-- CRM Customer Information
--------------------------------------------------------------
PRINT 'Loading CRM Customer Info...';
TRUNCATE TABLE bronze.crm_cust_info;
GO

BULK INSERT bronze.crm_cust_info
FROM '/home/mssql/source_crm/cust_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
GO

SELECT COUNT(*) AS [crm_cust_info_count] FROM bronze.crm_cust_info;
GO

--------------------------------------------------------------
-- CRM Product Information
--------------------------------------------------------------
PRINT 'Loading CRM Product Info...';
TRUNCATE TABLE bronze.crm_prd_info;
GO

BULK INSERT bronze.crm_prd_info
FROM '/home/mssql/source_crm/prd_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
GO

SELECT COUNT(*) AS [crm_prd_info_count] FROM bronze.crm_prd_info;
GO

--------------------------------------------------------------
-- CRM Sales Details
--------------------------------------------------------------
PRINT 'Loading CRM Sales Details...';
TRUNCATE TABLE bronze.crm_sales_details;
GO

BULK INSERT bronze.crm_sales_details
FROM '/home/mssql/source_crm/sales_details.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
GO

SELECT COUNT(*) AS [crm_sales_details_count] FROM bronze.crm_sales_details;
GO

-- ==========================================================
-- Load ERP Source Data
-- ==========================================================

--------------------------------------------------------------
-- ERP Location Data
--------------------------------------------------------------
PRINT 'Loading ERP Location Data...';
TRUNCATE TABLE bronze.erp_loc_a101;
GO

BULK INSERT bronze.erp_loc_a101
FROM '/home/mssql/source_erp/LOC_A101.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
GO

SELECT COUNT(*) AS [erp_loc_a101_count] FROM bronze.erp_loc_a101;
GO

--------------------------------------------------------------
-- ERP Customer Data
--------------------------------------------------------------
PRINT 'Loading ERP Customer Data...';
TRUNCATE TABLE bronze.erp_cust_az12;
GO

BULK INSERT bronze.erp_cust_az12
FROM '/home/mssql/source_erp/CUST_AZ12.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
GO

SELECT COUNT(*) AS [erp_cust_az12_count] FROM bronze.erp_cust_az12;
GO

--------------------------------------------------------------
-- ERP Product Category Data
--------------------------------------------------------------
PRINT 'Loading ERP Product Category Data...';
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
GO

BULK INSERT bronze.erp_px_cat_g1v2
FROM '/home/mssql/source_erp/PX_CAT_G1V2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);
GO

SELECT COUNT(*) AS [erp_px_cat_g1v2_count] FROM bronze.erp_px_cat_g1v2;
GO

-- ==========================================================
-- Summary: Verify Data Load
-- ==========================================================
PRINT 'Bronze Layer Data Load Summary';
SELECT 
    s.name AS SchemaName, 
    t.name AS TableName, 
    SUM(p.rows) AS RowCount
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE s.name = 'bronze' AND p.index_id IN (0,1)
GROUP BY s.name, t.name
ORDER BY TableName;
GO
