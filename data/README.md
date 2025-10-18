# data
this folder stores all datasets used throughout the **e-commerce etl + dq** project.  
it includes raw source data (kept locally) and public sample files showing before/after transformation and validation results

## structure
| folder / file | description |
|----------------|--------------|
| **`/data/sales_2023_raw.xlsx`** | full private source file containing raw transactional data used for local etl testing (not tracked in git). |
| **`/data/sample/sales_2023_raw_sample.xlsx`** | small, public sample showing ~30 rows from the raw dataset before cleaning and transformation. |
| **`/data/sample/sales_2023_final_sample.xlsx`** | same records as above, after full etl and validation. includes **demo dq sheets**:<br>– `dq_sales_2023_demo` (record-level validation showcase)<br>– `dq_summary_demo` (aggregated dq summary) | |

## file details
### sales_2023_raw.xlsx
- original input files used during the etl stage.  
- not included in git to protect sensitive or heavy data.  
- location: `/data/sales_2023_raw.xlsx` (local only).  
- used as source in queries under `/etl/queries/`.

### sales_2023_raw_sample.xlsx
- **purpose:** demonstrates the *before-etl* stage of the pipeline.  
- **contains:**  
  - inconsistent headers, mixed casing, mixed formats, non-standard country names, nulls, and formatting errors  
  - example records from `sales_q1`, `products`, `customer`, and `shipping`
- **use case:** to visualize data quality issues and understand initial cleaning requirements.

### sales_2023_final_sample.xlsx
- **purpose:** shows the *after-etl* result on the same subset of rows.  
- **contains:**  
  - standardized and validated versions of all columns  
  - unified naming conventions (snake_case)  
  - consistent numeric and date formatting  
  - resolved lookups and joined attributes from dimensions  
  - **two dq demonstration sheets** created purely for illustrative purposes:
    - **`dq_sales_2023_demo`** - record-level validation output with intentionally modified data to trigger rule violations  
    - **`dq_summary_demo`** - aggregated summary showing validation metrics and error/warning distribution  
    - **note:** both demo dq sheets contain *synthetic, edited data* designed to showcase how the dq functions (`fx_in_set`, `fx_is_between`, `fx_null_or_blank`, etc.) detect rule violations. <br>they **do not represent real project results** and are included solely for demonstration and documentation purposes.
- **use case:** to demonstrate the outcome of the etl + dq pipeline and provide a before/after comparison.

## usage notes
- raw data files are **excluded from git tracking** via .gitignore for privacy and storage optimization.  
- only **sample and demonstration files** are versioned publicly to illustrate etl + validation workflows.  
- all public examples are synthetic and safe sharing.

## related documentation
- [`etl-summary.md`](../docs/etl-summary.md) - overall etl + validation overview  
- [`etl-walkthrough.md`](../etl/etl-walkthrough.md) - full transformation steps  
- [`validation-walkthrough.md`](../validation/validation-walkthrough.md) - validation flow and dq results  
- [`data-dictionary.md`](../docs/data-dictionary.md) - column-level metadata reference  
- [`data-model.md`](../docs/data-model.md) - schema structure and relationships  

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
