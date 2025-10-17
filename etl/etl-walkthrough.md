# etl walkthrough
this document provides a detailed, step-by-step explanation of the power query etl process used in the **e-commerce etl + dq** project.  
it covers each transformation query, its logic, and how the final dataset `sales_2023` is constructed before validation and bi reporting.

## overview
the etl process transforms raw, fragmented operational data from multiple e-commerce sheets into a clean and analytics-ready data model.  
it begins with eight raw worksheets from one file - [`sales_2023_database_raw.xlsx`](../data/sample/sales_2023_database_raw.xlsx) - and ends with a unified dataset that integrates transactions, customers, products, fees, and shipping data.

the final output, `sales_2023`, is then passed to the validation stage (`/validation`), where data quality checks are performed.

## transformations by query
> for full m-code scripts, see [`/etl/queries`](./queries)

### 1. sales_q1
- **source:** `sales_2023_q1` sheet from `sales_2023_database_raw.xlsx`  
- **purpose:** cleans and standardizes q1 sales transactions.  
- **key operations:**
  - cleans headers and trims text using `fx_clean`  
  - standardizes column names (`order_id`, `order_date`, `customer_id`, etc.)  
  - parses `order_date` with `fx_date`  
  - validates numeric fields (`quantity`, `unit_price`) via `fx_number`  
  - applies `fx_country` to `order_country`  
  - standardizes text fields (`order_id`, `salesperson`, etc.) via `fx_text`
  - adds `salesperson_ascii` helper column (via `fx_diacritics`)  
  - removes duplicates by `order_id`
- **output:** cleaned q1 transactional data ready for merging.

### 2. sales_q2
- **source:** `Sales_2023_Q2` sheet  
- **purpose:** prepares q2 sales data in the same schema as q1.  
- **key operations:**
  - cleans headers and trims text using `fx_clean`  
  - standardizes column names (`order_id`, `order_date`, `customer_id`, etc.)  
  - parses `order_date` with `fx_date`  
  - validates numeric fields (`quantity`, `unit_price`) via `fx_number`  
  - applies `fx_country` to `order_country`  
  - standardizes text fields (`order_id`, `salesperson`, etc.) via `fx_text`
  - adds `salesperson_ascii` helper column (via `fx_diacritics`)  
  - removes duplicates by `order_id`
- **output:** harmonized q2 data compatible with q1.

### 3. sales_2023
- **purpose:** merges q1 and q2 data into one fact table and enriches it with product and customer attributes.  
- **key operations:**
  - combines `sales_q1` and `sales_q2` using `Table.Combine`  
  - removes duplicates by `order_id`  
  - adds derived column `sales_amount = quantity * unit_price`  
  - joins with `products` (adds `product_name`, `category`, `subcategory`, `unit_cost`)  
  - joins with `customers` (adds `customer_name`, `email`, `phone`, `customer_country`, `customer_city`, `segment`, and `ascii helper columns`)  
  - adds ascii helpers for cities (`order_city_ascii`)  
  - reorders columns
- **output:** complete fact table `sales_2023` used as the analytical foundation.

### 4. customers
- **source:** `customers` sheet  
- **purpose:** cleans and standardizes customer information.  
- **key operations:**
  - applies `fx_clean` and renames key columns (`customerid` → `customer_id`)
  - standardizes text fields (`customer_name`, `customer_city`, etc.) via `fx_text`
  - normalizes emails (`lowercase` + `fx_diacritics`)  
  - standardizes phone numbers (digits + one `+` allowed)  
  - standardizes country names via `fx_country`  
  - parses `join_date` using `fx_date`  
  - adds ascii helper columns (`customer_name_ascii`, `customer_city_ascii`)  
  - removes full-row duplicates  
- **output:** clean, standardized customer dimension table.

### 5. products
- **source:** `products` sheet  
- **purpose:** standardizes product data and packaging info.  
- **key operations:**
  - applies `fx_clean` and renames key columns (`sku` → `product_sku`)  
  - fixes data entry errors (`1` → `i`, `Bbq` → `BBQ`) and removes special characters from `product_name`
  - standardizes text fields (`product_name`, `category`, etc.) via `fx_text`
  - validates numeric field `unit_cost` via `fx_number`  
  - normalizes logical flag `active` via `fx_logical`  
  - parses `package_size` via `fx_package_size`, expanding `[pack_count, quantity, unit]`  
  - removes full-row duplicates  
- **output:** standardized product dimension ready for joins.

### 6. returns
- **source:** `returns` sheet  
- **purpose:** loads return transactions and ensures linkage with sales.  
- **key operations:**
  - cleans headers and trims text with `fx_clean`
  - renames columns (`return_id`, `return_date`, `order_id`)   
  - parses `return_date` using `fx_date`   
  - standardizes text fields via `fx_text`
  - removes duplicates by `return_id`  
- **output:** cleaned returns dataset consistent with `sales_2023`.

### 7. targets
- **source:** `targets_wide` sheet  
- **purpose:** reshapes monthly sales targets into long format.  
- **key operations:**
  - uses `Table.UnpivotOtherColumns` to transform wide months into `month` and `target_value` columns  
  - parses `target_value` via `fx_number`  
  - adds `month_number` using month name conversion (`Date.Month(Date.FromText(...))`)  
  - adds `salesperson_ascii` helper column  
  - removes full-row duplicates  
- **output:** tidy monthly sales targets ready for comparison with performance data.

### 8. fees
- **source:** `fees` sheet  
- **purpose:** standardizes marketplace fees across countries and channels.  
- **key operations:**
  - cleans headers and trims text with `fx_clean`  
  - applies `fx_text` to `channel` and `fee_type`  
  - validates numeric field `fee_value` via `fx_number`  
  - standardizes country names using `fx_country`  
  - renames and reorders columns for consistency  
  - removes duplicates by (`channel`, `country`, `fee_type`)
- **output:** clean fee reference table for dq and margin analysis.

### 9. shipping
- **source:** `shipping` sheet  
- **purpose:** parses shipping data and ensures correct order linkage.  
- **key operations:**
  - cleans headers and trims text with `fx_clean`  
  - splits `shippinginfo` into `carrier`, `delivery_type`, and `estimated_delivery_days`
  - standardizes text fields (`carrier`, `address`, etc.) via `fx_text`
  - validates numeric field `shipping_cost` via `fx_number`  
  - removes duplicates by `order_id`
- **output:** standardized shipping table with clear delivery and cost attributes.

## key transformation logic
| stage | description | main functions |
|--------|--------------|----------------|
| **cleaning** | removes nulls, trims text, normalizes headers | `fx_clean`, `fx_text` |
| **parsing** | converts raw text to structured formats (dates, numbers, booleans) | `fx_date`, `fx_number`, `fx_logical`, `fx_country` |
| **merging** | joins and enriches data across tables | `Table.NestedJoin`, `Table.ExpandTableColumn` |
| **aggregation** | calculates derived and summary fields | built-in power query aggregation + `fx_number` |
| **enrichment** | adds derived columns, ascii helpers, and normalized attributes | `fx_diacritics`, `fx_package_size`, `fx_text` |

## output tables
| table | description |
|--------|-------------|
| **sales_q1**, **sales_q2** | quarterly transaction tables cleaned and standardized. |
| **sales_2023** | unified fact table combining q1 + q2 and enriched with product and customer data. |
| **customers**, **products** | conformed dimension tables. |
| **returns**, **fees**, **targets**, **shipping** | supporting tables used for validation and enrichment. |

sample outputs available in [`/data/sample/sales_2023_sample.xlsx`](../data/sample/sales_2023_sample.xlsx).

## related documentation
- [**etl-pipeline**](./etl-pipeline.md)  
- [**etl-queries**](./queries)  
- [**etl-functions**](./functions)  
- [**validation-walkthrough**](../validation/validation-walkthrough.md)

## notes
- etl structure is modular, allowing easy extension for new quarters or regions.  

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
