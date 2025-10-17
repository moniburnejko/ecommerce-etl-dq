# validation walkthrough
this document describes the complete data quality (dq) validation process applied after the etl stage in the **e-commerce etl + dq** project.  
it explains how validation rules are defined, executed, and aggregated across all business entities.

## overview
after etl completion, all datasets (sales, products, customers, returns, shipping, targets, and fees) are fully cleaned and standardized.  
validation ensures referential integrity, logical accuracy, completeness, and consistency across all records.

validation outputs two main results:
- `dq_*` queries - table-level validation results  
- `dq_summary` - combined summary of validation findings across all datasets

sample outputs are stored in `/data/sample/sales_2023_sample.xlsx`.

## validation components
| component | location | description |
|------------|-----------|-------------|
| **validation_rules** | `/validation/validation-rules.md` | defines all dq rules applied to each table (sales, products, etc.) with rule name, target column, logic, and severity. |
| **validation functions** | `/validation/functions/` | contains reusable functions like `fx_null_or_blank`, `fx_is_between`, `fx_is_numeric`, and `fx_in_set` used across all dq queries. |
| **dq_*** | `/validation/queries/` | one query per entity (e.g., `dq_sales_2023.pq`, `dq_products.pq`); applies relevant rules to each table and outputs failed records. |
| **dq_summary** | `/validation/queries/dq_summary.pq` | consolidates all dq_* results and groups issues by table, field, rule, and severity. |

## validation flow
1. **load cleaned etl tables**
   - imports all processed datasets from `/etl/queries/`
   - buffers key reference lists (e.g., product_sku, customer_id)
2. **apply dq functions**
   - each dq_* query applies validation functions to its dataset:
     - `fx_null_or_blank` - missing field detection  
     - `fx_is_numeric` - numeric format validation  
     - `fx_is_between` - date and numeric range checks  
     - `fx_in_set` - category or code list validation  
   - failed records are wrapped using a helper function `as_issues()` that attaches metadata:  
     (`table_name`, `field`, `rule`, `severity`, `value`)
3. **generate issue tables**
   - each dq_* query outputs a table of issues (warnings and blockers)
   - results are consistent across all tables (same column schema)
4. **aggregate results**
   - `dq_summary` combines all dq_* outputs into a single dataset  
   - groups issues by:
     - table_name  
     - field  
     - rule  
     - severity (`blocker` / `warning`)  
   - calculates issue counts per table and percentage distribution
5. **output**
   - final summary stored as `dq_summary` (for reporting and dashboard integration)
   - detailed record-level issues remain accessible via `dq_*` tables

## datasets validated
| dataset | query file | main validation goals |
|----------|-------------|------------------------|
| `sales_2023` | `/validation/queries/dq_sales_2023.pq` | key completeness, numeric accuracy, foreign key integrity, valid currencies, and date ranges |
| `products` | `/validation/queries/dq_products.pq` | unique sku, valid ean codes, numeric costs, consistent package structures |
| `customers` | `/validation/queries/dq_customers.pq` | id presence, valid emails and phones |
| `returns` | `/validation/queries/dq_returns.pq` | valid order linkage, chronological dates (return after order) |
| `shipping` | `/validation/queries/dq_shipping.pq` | matching order id in sales, valid numeric cost |
| `targets` | `/validation/queries/dq_targets.pq` | valid salesperson, positive numeric target values |
| `fees` | `/validation/queries/dq_fees.pq` | valid numeric fee values, allowed fee types |

## rule definitions
all dq rules are defined in detail in:  
➡️ [`validation-rules.md`](./validation-rules.md)

## related documentation
- [/validation/functions/](./functions) - reusable validation helpers  
- [/validation/queries/](./queries) - per-table dq logic and summary  
- [/etl/etl-walkthrough.md](../etl/etl-walkthrough.md) - full etl process overview  
- [/data/sample/](../data/sample/) - example outputs from validation and dq summary  

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
