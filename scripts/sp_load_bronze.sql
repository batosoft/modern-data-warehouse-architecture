USE DataWarehouse;
GO

-- ==========================================================
-- Create or Alter Procedure with Time Profiling
-- ==========================================================
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '==========================================================';
    PRINT 'Starting Bronze Data Load Procedure';
    PRINT '==========================================================';

    BEGIN TRY
        DECLARE @start_time DATETIME, @end_time DATETIME;
        DECLARE @table_start DATETIME, @table_end DATETIME;

        -- For calculating the total execution time
        SET @start_time = GETDATE();

        --------------------------------------------------------------
        -- CRM Customer Information
        --------------------------------------------------------------
        PRINT 'Loading: bronze.crm_cust_info...';
        SET @table_start = GETDATE();

        TRUNCATE TABLE bronze.crm_cust_info;
        BULK INSERT bronze.crm_cust_info
        FROM '/home/mssql/source_crm/cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        SET @table_end = GETDATE();
        PRINT 'bronze.crm_cust_info loaded successfully. Duration: ' 
              + CAST(DATEDIFF(second, @table_start, @table_end) AS NVARCHAR) + ' seconds.';

        --------------------------------------------------------------
        -- CRM Product Information
        --------------------------------------------------------------
        PRINT 'Loading: bronze.crm_prd_info...';
        SET @table_start = GETDATE();

        TRUNCATE TABLE bronze.crm_prd_info;
        BULK INSERT bronze.crm_prd_info
        FROM '/home/mssql/source_crm/prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        SET @table_end = GETDATE();
        PRINT 'bronze.crm_prd_info loaded successfully. Duration: ' 
              + CAST(DATEDIFF(second, @table_start, @table_end) AS NVARCHAR) + ' seconds.';

        --------------------------------------------------------------
        -- CRM Sales Details
        --------------------------------------------------------------
        PRINT 'Loading: bronze.crm_sales_details...';
        SET @table_start = GETDATE();

        TRUNCATE TABLE bronze.crm_sales_details;
        BULK INSERT bronze.crm_sales_details
        FROM '/home/mssql/source_crm/sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        SET @table_end = GETDATE();
        PRINT 'bronze.crm_sales_details loaded successfully. Duration: ' 
              + CAST(DATEDIFF(second, @table_start, @table_end) AS NVARCHAR) + ' seconds.';

        --------------------------------------------------------------
        -- ERP Location Data
        --------------------------------------------------------------
        PRINT 'Loading: bronze.erp_loc_a101...';
        SET @table_start = GETDATE();

        TRUNCATE TABLE bronze.erp_loc_a101;
        BULK INSERT bronze.erp_loc_a101
        FROM '/home/mssql/source_erp/LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        SET @table_end = GETDATE();
        PRINT 'bronze.erp_loc_a101 loaded successfully. Duration: ' 
              + CAST(DATEDIFF(second, @table_start, @table_end) AS NVARCHAR) + ' seconds.';

        --------------------------------------------------------------
        -- ERP Customer Data
        --------------------------------------------------------------
        PRINT 'Loading: bronze.erp_cust_az12...';
        SET @table_start = GETDATE();

        TRUNCATE TABLE bronze.erp_cust_az12;
        BULK INSERT bronze.erp_cust_az12
        FROM '/home/mssql/source_erp/CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        SET @table_end = GETDATE();
        PRINT 'bronze.erp_cust_az12 loaded successfully. Duration: ' 
              + CAST(DATEDIFF(second, @table_start, @table_end) AS NVARCHAR) + ' seconds.';

        --------------------------------------------------------------
        -- ERP Product Category Data
        --------------------------------------------------------------
        PRINT 'Loading: bronze.erp_px_cat_g1v2...';
        SET @table_start = GETDATE();

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/home/mssql/source_erp/PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0A',
            TABLOCK
        );

        SET @table_end = GETDATE();
        PRINT 'bronze.erp_px_cat_g1v2 loaded successfully. Duration: ' 
              + CAST(DATEDIFF(second, @table_start, @table_end) AS NVARCHAR) + ' seconds.';

        --------------------------------------------------------------
        -- Total Patch Duration
        --------------------------------------------------------------
        SET @end_time = GETDATE();
        PRINT '==========================================================';
        PRINT 'Bronze Layer Data Load Completed Successfully!';
        PRINT 'Total Execution Duration: ' 
              + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds.';
        PRINT '==========================================================';

    END TRY

    BEGIN CATCH
        PRINT 'An error occurred during the Bronze data load.';
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO
