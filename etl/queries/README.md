# etl queries
this folder contains all power query m scripts used in the etl stage of the **e-commerce etl + dq** project.  
each query transforms, standardizes, and prepares one dataset that contributes to the unified data model `sales_2023`.

## contents
| file | description |
|------|--------------|
| **sales_q1.pq** | loads and cleans q1 transactional data, standardizing dates, text, and numeric fields. |
| **sales_q2.pq** | loads and prepares q2 transactional data, harmonized with q1 to enable quarterly merging. |
| **sales_2023.pq** | combines all quarterly sales tables, adds calculated fields, and performs joins with reference tables (`products`, `customers`). |
| **customers.pq** | standardizes customer info (id, name, email, phone, join_date) and creates ascii helper columns. |
| **products.pq** | normalizes product data, applies package size parsing, and validates ean / logical fields. |
| **returns.pq** | standardizes return records, including return dates, linked order id, and reason codes. |
| **targets.pq** | transforms wide monthly sales targets into tidy format and adds month_number column. |
| **fees.pq** | cleans and standardizes marketplace fees by country, channel, and fee type. |
| **shipping.pq** | parses combined shipping info (carrier, delivery type, estimated delivery days) and normalizes cost data. |

## integration flow
1. each raw sheet from `sales_2023_raw.xlsx` is imported individually  
2. transformations are applied using reusable etl functions (`fx_clean`, `fx_text`, `fx_number`, `fx_date`, etc.)  
3. all tables are cleaned and conformed to a consistent schema  
4. `sales_2023.pq` merges q1 and q2, adds computed metrics (`sales_amount`) and joins reference data  
5. the resulting dataset becomes the foundation for validation and reporting stages

## related documentation
- detailed walkthrough: [`etl-walkthrough.md`](../etl-walkthrough.md)  
- pipeline overview: [`etl-pipeline.md`](../etl-pipeline.md)  
- validation layer: [`/validation/`](../../validation/)  

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
