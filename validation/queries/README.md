# validation queries
this folder contains all power query (m language) scripts used in the data validation stage of the **e-commerce etl + dq** project.  
each query applies or summarizes data quality rules defined in `/validation/functions` and `/validation/validation-rules.md`.

## contents
| file | description |
|------|--------------|
| **dq_sales_2023.pq** | validates core transactional data (order id, currencies, quantities, prices, foreign keys, and date ranges). |
| **dq_products.pq** | checks product master data for sku uniqueness, numeric fields, valid ean codes, and consistent package structures. |
| **dq_customers.pq** | validates customer master data including id presence, country normalization, and email and phone format. |
| **dq_returns.pq** | ensures returns are linked to existing orders and that return_date occurs after order_date. |
| **dq_shipping.pq** | validates shipping data by confirming that order_id exist in sales_2023 and that delivery costs are valid. |
| **dq_targets.pq** | checks monthly target data for valid salesperson names and numeric target values. |
| **dq_fees.pq** | validates platform fee records for numeric fee values and recognized fee types. |
| **dq_summary.pq** | aggregates all dq_* results into a unified summary by table, field, rule, and severity level. |

## related documentation
- detailed walkthrough: [`validation-walkthrough.md`](../validation-walkthrough.md)  
- full rule definitions: [`validation-rules.md`](../validation-rules.md)  
- validation function reference: [`/validation/functions`](../functions)  
- related etl documentation: [`/etl/etl-pipeline.md`](../../etl/etl-pipeline.md) and [`/etl/etl-walkthrough.md`](../../etl/etl-walkthrough.md)

## notes
- each dq_* query outputs issues in a consistent format with columns:  
  `row_key`, `value`, `table_name`, `field`, `rule`, and `severity`.  
- `dq_summary` serves as the main reporting dataset for data quality dashboards.  
- sample inputs and aggregated validation outputs are available in `/data/sample/`.

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
