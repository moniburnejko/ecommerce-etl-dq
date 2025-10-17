# validation functions
this folder contains reusable power query (m language) helper functions for data quality (dq) checks across the e-commerce pipeline.  
they are used in dq_* queries to enforce business rules and detect data inconsistencies in tables such as sales, products, customers, returns, and shipping.  

## fx_null_or_blank
**purpose:** checks whether a field is null, empty, or whitespace-only.  
**main actions:**
- trims and evaluates text values as missing when blank  
- returns `true` for empty fields (e.g., missing `order_id`, `customer_id`, or `product_sku`)  
- used to identify incomplete transactional records  

## fx_is_numeric
**purpose:** verifies if a field can be safely converted to a number.  
**main actions:**
- attempts numeric conversion using `Number.From`  
- returns `true` only if conversion succeeds  
- used to validate metrics like `unit_price`, `quantity`, or `fee_value`  

## fx_is_between
**purpose:** validates whether a value falls within an expected numeric or date range.  
**main actions:**
- supports both numeric (e.g., `quantity`, `price`) and date (`order_date`, `return_date`) values  
- ensures logical consistency (e.g., date not outside 2023, quantity > 0)  
- used in date range and numeric limit validations  

## fx_in_set
**purpose:** checks whether a field matches one of a predefined set of allowed values.  
**main actions:**
- used to validate controlled lists like currencies (`PLN`, `EUR`, `USD`)
- handles null and case variations safely  
- used across sales, fees, and shipping validation  

## general notes
- functions are lightweight, composable, and null-safe.  
- designed to be used in dq_* queries for standardizing validation logic.  
- improve consistency and readability across multiple validation rule files.  

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
