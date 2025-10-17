# data dictionary
this document lists all tables and columns in the **e-commerce etl + dq** project. each section corresponds to one worksheet from the final workbook and includes column names, data types, short descriptions, and sample values.

## sales_2023
- role: **fact table**       
- description: central fact table containing all sales transactions with denormalized customer and product attributes for query performance.
- record count: 850
- grain: one row per order line item
- primary key: order_id

| column | type | description | example |
|---|---|---|---|
| `order_id` | text | unique order identifier | O389617 |
| `order_date` | date | transaction date | 2023-04-14 |
| `customer_id` | text | unique customer identifier | C1117 |
| `customer_name` | text | customer full name | Tomasz Wiśniewski |
| `customer_name_ascii` | text | customer name (ascii) | Tomasz Wisniewski |
| `email` | text | customer email (lowercased) | tomasz.wisniewski@firma.pl |
| `phone` | text | customer phone (digits + optional +) | +49550617568 |
| `customer_country` | text | customer country (standardized) | Poland |
| `customer_city` | text | customer city (as provided) | Wrocław |
| `customer_city_ascii` | text | customer city (ascii) | Wroclaw |
| `segment` | text | customer segment | VIP |
| `product_sku` | text | product stock keeping unit | P6977-B |
| `product_name` | text | product display name | Green Tea |
| `category` | text | product category | Beverages |
| `subcategory` | text | product subcategory | Tea |
| `unit_cost` | number (decimal) | unit purchase cost | 12.50 |
| `quantity` | number (integer) | ordered quantity (units) | 3 |
| `unit_price` | number (decimal) | unit selling price | 18.90 |
| `sales_amount` | number (decimal) | quantity × unit_price | 56.70 |
| `currency` | text | transaction currency code | PLN |
| `order_country` | text | order country (standardized) | Poland |
| `order_city` | text | order city (as provided) | Kraków |
| `order_city_ascii` | text | order city (ascii) | Krakow |
| `channel` | text | sales channel/source | Online |
| `salesperson` | text | sales representative name | A. Zielińska |
| `salesperson_ascii` | text | salesperson (ascii) | A. Zielinska |

## products
- role: **dimension**       
- description: product master data with specifications and attributes.
- record count: 60
- grain: one row per product
- primary key: product_sku
- relationship: one-to-many with sales_2023

| column | type | description | example |
|---|---|---|---|
| `product_sku` | text | product stock keeping unit | P6111-D |
| `product_name` | text | product display name | Shampoo |
| `category` | text | product category | Personal Care |
| `subcategory` | text | product subcategory | Cosmetics |
| `unit_cost` | number (decimal) | unit purchase cost | 24.99 |
| `pack_count` | number (integer) | items per pack | 6 |
| `quantity` | number (decimal) | normalized item size (see unit) | 0.5 |
| `unit` | text | measurement unit (e.g., L, kg) | L |
| `ean` | number (integer) | ean-13 barcode | 0590102488789 |
| `active` | logical | product active flag | true |
| `supplier` | text | supplier name | Eurosupply |

## customers
- role: **dimension**        
- description: customer master data with contact information and segmentation.
- record count: 120
- grain: one row per customer
- primary key: customer_id
- relationship: one-to-many with sales_2023

| column | type | description | example |
|---|---|---|---|
| `customer_id` | text | unique customer identifier | C1009 |
| `customer_name` | text | customer full name | Igor Wójcik |
| `customer_name_ascii` | text | customer name (ascii) | Igor Wojcik|
| `email` | text | customer email (lowercased) | igor.wojcik@email.com |
| `phone` | text | customer phone (digits + optional +) | +42672987290 |
| `customer_country` | text | customer country (standardized) | Austria |
| `customer_city` | text | customer city (as provided) | Vienna |
| `customer_city_ascii` | text | customer city (ascii) | Vienna |
| `segment` | text | customer segment | Enterprise |
| `vat` | text | tax id / vat | DE380004069 |
| `joindate` | date | customer join date | 2018-11-01 |

## shipping
- role: **supporting**
- description: shipping details for delivered orders (Poland market only).
- record count: 200
- coverage: Poland orders only (~24% of total)
- primary key: order_id
- relationship: one-to-one with sales_2023

| column | type | description | example |
|---|---|---|---|
| `order_id` | text | unique order identifier | O143010 |
| `carrier` | text | shipping carrier | DHL |
| `delivery_type` | text | delivery service type | Express |
| `estimated_delivery_days` | text | estimated delivery time (days) | 1-2 |
| `cost_pln` | number (decimal) | shipping cost in PLN | 41.14 |
| `address` | text | shipping address (single field) | ul. Jana 3, 00-001 Warszawa |

## fees
- role: **supporting**      
- description: fee structure for sales channels (Poland market only).
- record count: 6
- coverage: Poland only
- relationship: many-to-one with sales_2023

| column | type | description | example |
|---|---|---|---|
| `channel` | text | sales channel/source | Retail |
| `country` | text | order country (standardized) | Poland |
| `fee_type` | text | fee type (%, Flat) | % |
| `fee_value` | number (decimal) | fee value (amount or percent) | 5 |

## targets
- role: **supporting**      
- description: monthly sales targets by salesperson.
- record count: 42
- grain: one row per salesperson + month
- relationship: many-to-one with sales_2023

| column | type | description | example |
|---|---|---|---|
| `salesperson` | text | sales representative name | J. Kowal |
| `salesperson_ascii` | text | salesperson (ascii) | J. Kowal |
| `month` | text | month name (standardized) | May |
| `month_number` | number (integer) | month number (1-12) | 5 |
| `target_value` | number (decimal) | monthly sales target value | 53311 |
| `note` | text | free-form note | includes online share |

## returns
- role: **supporting**
- description: post-sale return transactions linked to orders.
- record count: 40
- grain: one row per return
- primary key: return_id
- relationship: one-to-many with sales_2023

| column | type | description | example |
|---|---|---|---|
| `return_id` | text | unique return identifier | R10036 |
| `return_date` | date | date of return | 2023-07-05 |
| `order_id` | text | unique order identifier | O301998 |
| `reason` | text | return reason | Damaged |
| `status` | text | return status | Approved |

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
