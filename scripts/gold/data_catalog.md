# Data Catalog – Gold Layer
**Version:** 2025-11-09  
**Purpose:** Documentation for dimensional and fact tables in the Gold layer.

---

## 1. Overview

| Table / View Name       | Type      | Description                                                                 |
|-------------------------|-----------|-----------------------------------------------------------------------------|
| `gold.dim_customers`    | Dimension | Customer dimension with surrogate key, cleaned gender, and country info.   |
| `gold.dim_products`     | Dimension | Product dimension with surrogate key, category, subcategory, and cost.    |
| `gold.fact_sales`       | Fact      | Sales fact table linking customers and products with sales metrics.       |

---

## 2. Customer Dimension (`gold.dim_customers`)

| Column Name       | Data Type | Description / Notes                                                |
|------------------|-----------|-------------------------------------------------------------------|
| `customer_key`    | INT       | Surrogate key (generated via ROW_NUMBER).                          |
| `customer_id`     | INT       | Original CRM customer ID.                                          |
| `customer_number` | VARCHAR   | CRM customer number (`cst_key`).                                    |
| `first_name`      | VARCHAR   | Customer first name.                                               |
| `last_name`       | VARCHAR   | Customer last name.                                                |
| `marital_status`  | VARCHAR   | Customer marital status (from CRM).                                |
| `gender`          | VARCHAR   | Cleaned gender (CRM master, fallback to ERP).                     |
| `create_date`     | DATE      | Customer creation date.                                            |
| `birthdate`       | DATE      | Customer birthdate (from ERP).                                     |
| `country`         | VARCHAR   | Country (from ERP location table).                                 |

---

## 3. Product Dimension (`gold.dim_products`)

| Column Name      | Data Type | Description / Notes                                                |
|-----------------|-----------|-------------------------------------------------------------------|
| `product_key`    | INT       | Surrogate key (generated via ROW_NUMBER).                          |
| `product_id`     | INT       | Original CRM product ID.                                           |
| `product_number` | VARCHAR   | CRM product number (`prd_key`).                                     |
| `product_name`   | VARCHAR   | Product name.                                                      |
| `category_id`    | INT       | Product category ID (`cat_id`).                                     |
| `category`       | VARCHAR   | Category name (from ERP).                                          |
| `subcategory`    | VARCHAR   | Subcategory name (from ERP).                                       |
| `maintenance`    | VARCHAR   | Maintenance flag/indicator (from ERP).                             |
| `cost`           | DECIMAL   | Product cost.                                                      |
| `product_line`   | VARCHAR   | Product line.                                                      |
| `start_date`     | DATE      | Product start date.                                                |

---

## 4. Sales Fact Table (`gold.fact_sales`)

| Column Name      | Data Type | Description / Notes                                                |
|-----------------|-----------|-------------------------------------------------------------------|
| `order_number`   | VARCHAR   | Sales order number (from CRM).                                     |
| `product_key`    | INT       | Surrogate key referencing `dim_products`.                         |
| `customer_key`   | INT       | Surrogate key referencing `dim_customers`.                        |
| `order_date`     | DATE      | Order creation date.                                               |
| `shipping_date`  | DATE      | Shipping date of the order.                                        |
| `due_date`       | DATE      | Due date for the order.                                            |
| `sales_amount`   | DECIMAL   | Total sales amount for the order line.                             |
| `quantity`       | INT       | Quantity sold.                                                     |
| `price`          | DECIMAL   | Unit price for the product.                                        |

---

## 5. Additional Notes

1. `dim_customers` is the master for gender; fallback to ERP data if missing.  
2. `dim_products` filters out historical products (`prd_end_dt IS NULL`).  
3. `fact_sales` replaces original keys with **dimension surrogate keys** for star schema consistency.  
4. All views are **versioned and replaceable**, safe for ETL pipelines.  
