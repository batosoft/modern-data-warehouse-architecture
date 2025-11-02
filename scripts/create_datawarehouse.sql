-- ==========================================================
--  Script: create_datawarehouse.sql
--  Description: Creates the DataWarehouse database and its schemas
--  Author: Basem Torky
--  Date:   2025-11-02
-- ==========================================================

-- Switch to master database
USE master;
GO

-- Create the Data Warehouse database
CREATE DATABASE DataWarehouse;
GO

-- Switch context to the new database
USE DataWarehouse;
GO

-- ==========================================================
--  Create Schemas
-- ==========================================================

-- Bronze Layer: Raw data as-is from source systems
CREATE SCHEMA bronze;
GO

-- Silver Layer: Cleansed and standardized data
CREATE SCHEMA silver;
GO

-- Gold Layer: Business-ready, aggregated data
CREATE SCHEMA gold;
GO

-- ==========================================================
--  Verification
-- ==========================================================
-- View all schemas in the database
SELECT name AS SchemaName 
FROM sys.schemas 
ORDER BY name;
GO
