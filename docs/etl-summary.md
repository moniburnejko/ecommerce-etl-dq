# etl + validation summary
this document provides a concise overview of the **e-commerce etl + dq** project - an end-to-end data pipeline that transforms and validates sales data using **power query m**.

## overview
the project processes multi-source e-commerce data covering sales transactions, product data, customer profiles, fees, shipping, and returns. all data comes from one raw workbook: `sales_2023_raw.xlsx`.      

sample input file available in: [`/data/sample/sales_2023_raw_sample.xlsx`](../data/sample/sales_2023_raw_sample.xlsx).

the etl pipeline standardizes, merges, and enriches these datasets into a unified analytical model - `sales_2023` - later validated in the `/validation` stage.  

## etl highlights
| stage | description | key functions |
|--------|-------------|----------------|
| **cleaning** | removes empty rows, trims text, and standardizes column names | `fx_clean`, `fx_text` |
| **standardization** | parses dates, numbers, and logicals into consistent formats | `fx_date`, `fx_number`, `fx_logical`, `fx_country` |
| **integration** | merges q1 and q2 sales, joins with products and customers | `Table.Combine`, `Table.NestedJoin` |
| **enrichment** | adds calculated fields (`sales_amount`, `ascii helpers`, derived dimensions) | `fx_diacritics`, `fx_package_size` |
| **final dataset** | outputs fully standardized `sales_2023` fact table | `sales_2023.pq` |

for a detailed description of each transformation stage, see:  
➡️ [`etl-walkthrough.md`](../etl/etl-walkthrough.md)

## validation overview
the validation layer ensures the consistency, completeness, and referential integrity of all datasets before analysis.  
validation rules are defined in [`/validation/validation-rules.md`](../validation/validation-rules.md) and executed through dedicated dq queries.  

for a detailed explanation of the validation logic, see:  
➡️ [`validation-walkthrough.md`](../validation/validation-walkthrough.md)

**core outputs:**
- `dq_sales_2023` - validates transactional data integrity (`order_id`, `currency`, fk relationships, etc.)  
- `dq_products`, `dq_customers`, `dq_returns`, `dq_fees`, `dq_shipping`, `dq_targets` - dataset-specific dq checks  
- `dq_summary` - aggregated summary of all detected data quality issues by table, field, and severity  

sample output:  
[`/data/sample/sales_2023_sample.xlsx`](../data/sample/sales_2023_sample.xlsx)

## project structure
| folder | description |
|---------|--------------|
| [`/etl`](../etl) | full power query etl pipeline: extraction, transformation, and enrichment |
| [`/validation`](../validation) | data quality and validation layer including dq rules and metrics |
| [`/data`](../data) | raw source files and sample validated outputs |
| [`/docs`](../docs) | project documentation, data model, and dictionary |

## results
- **unified dataset:** `sales_2023` - standardized and enriched transaction data, integrated with customers and products  
- **validated dataset:** `dq_sales_2023` - full record-level dq output including failed rule logs and severity tags  
- **summary report:** `dq_summary` - aggregated dq metrics across all sources  
- **final output:** data ready for analytical dashboards and bi integration  

## notes
- modular function design allows easy extension to new datasets (e.g., `sales_2024_q1`).  
- full documentation available in:  
  - [`etl-pipeline.md`](../etl/etl-pipeline.md)  
  - [`etl-walkthrough.md`](../etl/etl-walkthrough.md)  
  - [`validation-walkthrough.md`](../validation/validation-walkthrough.md)

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
