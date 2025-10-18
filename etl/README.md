# etl
this folder contains all scripts, documentation, and helper functions used in the power query extract-transform-load (etl) process for the **e-commerce etl + dq** project.  
the etl stage prepares raw excel data for validation and reporting by cleaning, standardizing, merging, and enriching multiple e-commerce data sources into a unified analytical dataset.

## folder structure
| path | description |
|----------------|-------------|
| [`etl-pipeline.md`](etl-pipeline.md)| high-level architecture overview describing the full etl flow, from raw data import to final unified dataset. |
| [`etl-walkthrough.md`](etl-walkthrough.md) | detailed, step-by-step explanation of each etl query and transformation stage. includes key operations, function usage, and outputs. |
| [`/functions`](functions) | reusable power query (m language) functions used across all etl scripts. includes text, numeric, date, and package parsing utilities. |
| [`/queries`](queries) | main transformation logic. contains one query per dataset (`sales_q1`, `sales_q2`, `customers`, `products`, etc.) and a master query `sales_2023.pq` that merges and enriches all data. |

## data source
- the etl process loads all input data from a single raw excel file: `sales_2023_raw.xlsx`.
- the workbook contains the following worksheets: `sales_2023_q1`, `sales_2023_q2`, `customers`, `products`, `returns`, `fees`, `targets_wide`, `shipping`.
- sample input file available in: [`/data/sample/sales_2023_raw_sample.xlsx`](../data/sample/sales_2023_raw_sample.xlsx)

## output datasets
| dataset | description |
|----------|-------------|
| **sales_2023** | final fact table combining q1 and q2 sales data with customer and product metadata. |
| **customers**, **products** | standardized dimension tables used for joins and dq validation. |
| **returns**, **fees**, **targets**, **shipping** | supporting datasets integrated into the analytical model. |

all output tables are later validated in the [`/validation`](../validation) stage, where dq checks (`dq_sales_2023`, `dq_products`, `dq_customers`, etc.) assess completeness, consistency, and referential integrity.  

sample outputs are available in [`/data/sample/sales_2023_final_sample.xlsx`](../data/sample/sales_2023_final_sample.xlsx).

## process summary
1. **extract** - load and promote headers from all worksheets using `fx_clean`.  
2. **transform** - clean and standardize all fields:  
   - text → `fx_text`, `fx_diacritics`  
   - numbers → `fx_number`  
   - dates → `fx_date`  
   - logicals → `fx_logical`  
   - packaging → `fx_package_size`  
3. **load** - combine, deduplicate, and enrich all data into a final fact table `sales_2023`.  
4. **handoff** - pass the processed dataset to the validation stage for data quality assessment.  

## related documentation
- [**etl-pipeline.md**](./etl-pipeline.md) - high-level process architecture  
- [**etl-walkthrough.md**](./etl-walkthrough.md) - detailed query walkthrough  
- [**/validation/**](../validation) - data quality and validation layer  
- [**/data/sample/**](../data/sample) - reference inputs and outputs  

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
