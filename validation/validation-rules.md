# validation rules
this document lists all data quality validation rules applied to the e-commerce etl project.  
each rule defines its target table, column, logic, and severity level.

## rule fields
| field | description |
|--------|-------------|
| `rule_name` | unique rule identifier |
| `target_table` | name of the dataset the rule applies to |
| `target_column` | validated field name |
| `rule_logic` | validation type or function used |
| `parameters` | optional arguments (range, list, or reference keys) |
| `severity` | classification of rule violation: `blocker` or `warning` |

## sales_2023
| rule_name | target_column | rule_logic | parameters | severity |
|------------|----------------|-------------|-------------|-----------|
| missing_order_id | order_id | fx_null_or_blank | n/a | blocker |
| invalid_currency | currency | fx_in_set | {"PLN","EUR","USD"} | blocker |
| invalid_unit_price | unit_price | fx_is_numeric & ≥ 0 | n/a | blocker |
| invalid_quantity | quantity | fx_is_numeric & ≥ 1 | n/a | blocker |
| invalid_product_fk | product_sku | fx_in_set(products[product_sku]) | n/a | blocker |
| invalid_customer_fk | customer_id | fx_in_set(customers[customer_id]) | n/a | blocker |
| invalid_order_date | order_date | fx_is_between | (#date(2023,1,1), #date(2023,12,31)) | blocker |

## products
| rule_name | target_column | rule_logic | parameters | severity |
|------------|----------------|-------------|-------------|-----------|
| missing_sku | product_sku | fx_null_or_blank | n/a | blocker |
| missing_product_name | product_name | fx_null_or_blank | n/a | warning |
| invalid_ean | ean | len = 13 | n/a | blocker |
| invalid_unit_cost | unit_cost | fx_is_numeric & ≥ 0 | n/a | blocker |
| invalid_package_structure | pack_count / quantity / unit | fx_is_numeric (all) | n/a | warning |

## customers
| rule_name | target_column | rule_logic | parameters | severity |
|------------|----------------|-------------|-------------|-----------|
| missing_customer_id | customer_id | fx_null_or_blank | n/a | blocker |
| missing_customer_name | customer_name | fx_null_or_blank | n/a | warning |
| missing customer_country | customer_country | fx_null_or_blank | n/a | warning |
| invalid_email | email | pattern check (contains "@") | n/a | warning |
| invalid_phone | phone | length check (≥ 9) | n/a | warning |

## returns
| rule_name | target_column | rule_logic | parameters | severity |
|------------|----------------|-------------|-------------|-----------|
| missing_return_id | return_id | fx_null_or_blank | n/a | blocker |
| invalid_return_date | return_date | fx_is_between | (#date(2023,1,1), #date(2023,12,31)) | warning |
| invalid_order_fk | order_id | fx_in_set(sales_2023[order_id]) | n/a | blocker |
| invalid_date_sequence | return_date > order_date | relational check | linked via order_id | blocker |

## shipping
| rule_name | target_column | rule_logic | parameters | severity |
|------------|----------------|-------------|-------------|-----------|
| missing_order_id | order_id | fx_null_or_blank | n/a | blocker |
| missing_order_fk | order_id | fx_in_set(sales_2023[order_id]) | n/a | blocker |
| invalid_cost_pln | cost_pln | fx_is_numeric & ≥ 0 | n/a | warning |
| missing_address | address | fx_null_or_blank | n/a | info |

## targets
| rule_name | target_column | rule_logic | parameters | severity |
|------------|----------------|-------------|-------------|-----------|
| missing_salesperson | salesperson | fx_null_or_blank | n/a | blocker |
| invalid_target_value | target_value | fx_is_numeric & ≥ 0 | n/a | blocker |

## fees
| rule_name | target_column | rule_logic | parameters | severity |
|------------|----------------|-------------|-------------|-----------|
| invalid_channel | channel | fx_null_or_blank | n/a| blocker |
| missing_country | country | fx_null_or_blank | n/a | warning |
| invalid_fee_type | fee_type | fx_in_set | {"%","Flat"} | warning |
| invalid_fee_value | fee_value | fx_is_numeric & ≥ 0 | n/a | blocker |

## summary
- total rules defined: **31**  
- core validation functions: `fx_null_or_blank`, `fx_is_numeric`, `fx_is_between`, `fx_in_set`  
- relational checks implemented in: `dq_sales_2023`, `dq_returns`, `dq_shipping`  
- results aggregated in [`dq_summary.pq`](./queries/dq_summary.pq)

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
