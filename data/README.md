# data
this folder stores all datasets used throughout the **e-commerce etl + dq** project.  
it includes raw source data (kept locally) and public sample files showing before/after transformation and validation results

## structure
| folder / file | description |
|----------------|--------------|
| **`/data/sales_2023_raw.xlsx`** | full private source file containing raw transactional data used for local etl testing (not tracked in git). |
| **`/data/sample/sales_2023_raw_sample.xlsx`** | small, public sample showing ~? rows from the raw dataset before cleaning and transformation. |
| **`/data/sample/sales_2023_final_sample.xlsx`** | same records as above, after full etl and validation (clean, standardized, ready for bi). |
| **`/data/sample/dq_sales_2023_demo`** *(sheet inside)* | synthetic validation output demonstrating how dq rules flag data issues. |

## file details
### sales_2023_raw.xlsx
- original input files used during the etl stage.  
- not included in git to protect sensitive or heavy data.  
- location: `/data/sales_2023_raw.xlsx` (local only).  
- used as source in queries under `/etl/queries/`.

### sales_2023_raw_sample.xlsx
- **purpose:** demonstrates the *before-etl* stage of the pipeline.  
- **contains:**  
  - inconsistent headers, mixed casing, non-standard country names, nulls, and formatting errors  
  - partial data from key tables: `sales_q1`, `sales_q2`, `customers`, `products`, `returns`, `fees`, `shipping`, `targets`  
- **use case:** to visualize data quality issues and understand initial cleaning requirements.

### sales_2023_final_sample.xlsx
- **purpose:** shows the *after-etl* result on the same subset of rows.  
- **contains:**  
  - standardized and validated versions of all columns  
  - unified naming conventions (snake_case)  
  - consistent numeric and date formatting  
  - resolved lookups (joined `products`, `customers`)  
  - sheet **`dq_sales_2023_demo`** with example validation output  
    *(the data in this sheet was created intentionally to showcase the validation process and demonstrate how data quality rules are applied - even when the real dataset has few or no issues)*
  - **use case:** to demonstrate the outcome of the etl + dq pipeline and provide a before/after comparison.

## usage notes
- raw data files are **excluded from git tracking** via .gitignore for privacy and storage optimization.  
- only **sample and final sample files** are versioned publicly to illustrate etl + validation workflows.  
- all public examples are synthetic and safe sharing.

## related documentation
- [`etl-summary.md`](../docs/etl-summary.md) - overall etl + validation overview  
- [`etl-walkthrough.md`](../etl/etl-walkthrough.md) - full transformation steps  
- [`validation-walkthrough.md`](../validation/validation-walkthrough.md) - validation flow and dq results  
- [`data-dictionary.md`](../docs/data-dictionary.md) - column-level metadata reference  
- [`data-model.md`](../docs/data-model.md) - schema structure and relationships  

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
