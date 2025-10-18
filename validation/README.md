# data validation
this folder contains all power query (m language) components responsible for data validation and data quality (dq) control within the **e-commerce etl + dq** project.  
validation ensures consistency, completeness, and logical accuracy across all datasets produced during the etl stage.

## structure
| subfolder / file | description |
|------------------|-------------|
| **/functions/** | reusable dq helper functions (e.g., `fx_null_or_blank`, `fx_in_set`, `fx_is_numeric`, `fx_is_between`) used across all validation queries. |
| **/queries/** | power query scripts (`dq_*`) that apply validation rules and generate issue summaries per dataset. |
| **validation-walkthrough.md** | full documentation of the validation flow, logic components, and outputs. |
| **validation-rules.md** | detailed list of all dq rules, including target table, column, logic, parameters, and severity. |

## validation overview
the validation stage runs immediately after the etl pipeline finishes.  
it performs a structured set of dq checks across all tables (`sales_2023`, `products`, `customers`, `returns`, `shipping`, `targets`, and `fees`).

each dq_* query:
- loads the cleaned etl output from `/etl/queries/`
- applies dq functions to detect nulls, invalid numeric values, range violations, and missing foreign keys
- uses `as_issues()` to create standardized issue tables
- returns consistent columns:  
  `row_key`, `value`, `table_name`, `field`, `rule`, `severity`

the results are combined into `dq_summary`, which aggregates all detected issues by table, field, and rule severity.

## related documentation
| document | description |
|-----------|-------------|
| [`validation-walkthrough.md`](./validation-walkthrough.md) | describes the complete validation flow, dependencies, and dq summary generation. |
| [`validation-rules.md`](./validation-rules.md) | defines all applied rules and their validation logic. |
| [`/validation/functions/`](./functions) | reference for all reusable validation functions. |
| [`/validation/queries/`](./queries) | contains individual dq_* scripts and the final `dq_summary`. |
| [`/etl/etl-walkthrough.md`](../etl/etl-walkthrough.md) | documentation of upstream etl logic and data standardization. |

## outputs
- record-level dq tables: `dq_sales_2023`, `dq_products`, `dq_customers`, `dq_returns`, `dq_shipping`, `dq_targets`, `dq_fees`
- aggregated dq summary: `dq_summary`
- small **synthetic demo output** is included in [`/data/sample/sales_2023_final_sample.xlsx`](../data/sample/sales_2023_final_sample.xlsx).

## notes
- dq logic is modular and can be easily extended with new rules or entities.  
- null and blank detection uses a consistent function set to ensure reproducible validation results.  

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
