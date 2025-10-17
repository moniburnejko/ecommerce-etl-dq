# docs
this folder contains all high-level documentation for the **e-commerce etl + dq** project.  
it explains how data moves through the etl pipeline, how validation is performed, and how the final data model is structured for analytics and reporting.

## folder contents
| file | description |
|------|--------------|
| [`etl-summary.md`](etl-summary.md) | short overview of the full etl + validation workflow and key project outputs. |
| [`data-dictionary.md`](data-dictionary.md) | detailed table-by-table description of all fields, data types, and sample values. |
| [`data-model.md`](data-model.md) | explains the project’s hybrid star schema, table relationships, and design decisions. |

## how to navigate
1. **start here:**  
   read [`etl-summary.md`](./etl-summary.md) to understand the overall project flow.  
2. **then explore:**  
   - [`data-model.md`](./data-model.md) to see how the data is structured.  
   - [`data-dictionary.md`](./data-dictionary.md) for a full field reference.  
3. **for technical details:**  
   - [`/etl/etl-walkthrough.md`](../etl/etl-walkthrough.md)  
   - [`/validation/validation-walkthrough.md`](../validation/validation-walkthrough.md)

## related assets
- data model diagram → [`data-model-diagram.png`](./data-model-diagram.png)  
- sample outputs → [`/data/sample/`](../data/sample/)  

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
