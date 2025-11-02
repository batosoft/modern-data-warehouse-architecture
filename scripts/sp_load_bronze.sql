-- ==========================================================
-- Script: sp_load_bronze.sql
-- Description: Stored Procedure to load Bronze layer tables
--              from CRM and ERP CSV source files.
-- Author: Basem Torky
-- Date:   2025-11-02
-- ==========================================================

USE DataWarehouse;
GO

-- ==========================================================
-- Create or Alter Procedure
-- ==========================================================
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '==========================================================';
    PRINT 'Starting Bronze Data Load Procedure';
    PRINT '==========================================================';

    BEGIN TRY

        --------------------------------------------------------------
        -- CRM Customer Information
        --------------------------------------------------------------
        PRINT 'Loading: bronze.crm_cust_info...';
        TRUNCATE TABLE bronze.crm_cust_info;

        BULK INSERT bronze.crm_cust_info
        FROM '/home/mssql/source_crm/cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        PRINT 'bronze.crm_cust_info loaded successfully.';


        --------------------------------------------------------------
        -- CRM Product Information
        --------------------------------------------------------------
        PRINT 'Loading: bronze.crm_prd_info...';
        TRUNCATE TABLE bronze.crm_prd_info;

        BULK INSERT bronze.crm_prd_info
        FROM '/home/mssql/source_crm/prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        PRINT 'bronze.crm_prd_info loaded successfully.';


        --------------------------------------------------------------
        -- CRM Sales Details
        --------------------------------------------------------------
        PRINT 'Loading: bronze.crm_sales_details...';
        TRUNCATE TABLE bronze.crm_sales_details;

        BULK INSERT bronze.crm_sales_details
        FROM '/home/mssql/source_crm/sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        PRINT 'bronze.crm_sales_details loaded successfully.';


        --------------------------------------------------------------
        -- ERP Location Data
        --------------------------------------------------------------
        PRINT 'Loading: bronze.erp_loc_a101...';
        TRUNCATE TABLE bronze.erp_loc_a101;

        BULK INSERT bronze.erp_loc_a101
        FROM '/home/mssql/source_erp/LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        PRINT 'bronze.erp_loc_a101 loaded successfully.';


        --------------------------------------------------------------
        -- ERP Customer Data
        --------------------------------------------------------------
        PRINT 'Loading: bronze.erp_cust_az12...';
        TRUNCATE TABLE bronze.erp_cust_az12;

        BULK INSERT bronze.erp_cust_az12
        FROM '/home/mssql/source_erp/CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        PRINT 'bronze.erp_cust_az12 loaded successfully.';


        --------------------------------------------------------------
        -- ERP Product Category Data
        --------------------------------------------------------------
        PRINT 'Loading: bronze.erp_px_cat_g1v2...';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/home/mssql/source_erp/PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        PRINT 'bronze.erp_px_cat_g1v2 loaded successfully.';

        --------------------------------------------------------------
        -- Summary
        --------------------------------------------------------------
        PRINT '==========================================================';
        PRINT 'Bronze Layer Data Load Completed Successfully!';
        PRINT '==========================================================';

    END TRY

    BEGIN CATCH
        PRINT 'An error occurred during the Bronze data load.';
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- ==========================================================
-- Execute the Procedure
-- ==========================================================
-- EXEC bronze.load_bronze;
-- GO
