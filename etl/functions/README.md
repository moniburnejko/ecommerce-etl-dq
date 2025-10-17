# etl functions
this folder contains a collection of reusable power query (m language) functions used across the e-commerce etl pipeline.  
each function includes in-code comments describing the key transformation steps and logic.  

## fx_clean
**purpose:** cleans and standardizes raw sales and reference tables before processing.  
**main actions:**
- removes fully empty rows  
- trims whitespace in all text fields  
- converts column names to lowercase snake_case  
- standardizes headers like `Unit Price (PLN)` → `unit_price_pln`  

## fx_text
**purpose:** cleans and normalizes text fields such as product names, cities, channels, and salesperson names.  
**main actions:**
- removes control characters, tabs, and extra spaces  
- replaces non-breaking spaces (nbsp) with standard spaces  
- normalizes punctuation (e.g., “–” and “—” → “-”)  
- supports casing options: `"lower"`, `"upper"`, `"proper"` (default), or `"none"`  

## fx_number
**purpose:** safely converts text or mixed-type numeric fields into numbers.  
**main actions:**
- standardizes decimal separators (`,` → `.`)  
- removes fuzzy tokens like `≈`, `~`, and non-breaking spaces  
- handles values like `7,5` → `7.5` or `1 200` → `1200`  
- supports both integer (`quantity`) and decimal (`unit_price`) contexts  

## fx_date
**purpose:** parses various date formats from source sheets into valid date values.  
**main actions:**
- detects and converts excel serial numbers (e.g., `45123` → `2023-07-10`)  
- supports ISO-like and local formats (`dd/mm/yyyy`, `mm-dd-yyyy`, etc.)  
- normalizes separators (`.`, `/` → `-`)  
- supports multiple cultures (default: `{"en-GB","en-US","pl-PL"}`)  

## fx_country
**purpose:** standardizes country names from sales, customers, or shipping tables.  
**main actions:**
- maps multilingual and abbreviated country names to consistent English values  
- examples: `pl`, `polska`, `republic of poland` → `Poland`; `de`, `deutschland` → `Germany`  
- ensures consistent country naming across all tables before joins  

## fx_diacritics
**purpose:** removes polish diacritics for ascii-safe text comparisons.  
**main actions:**
- replaces accented letters with base characters (e.g., `Gdańsk` → `Gdansk`)  
- used to create helper columns such as `customer_city_ascii` or `salesperson_ascii`  

## fx_logical
**purpose:** converts text or numeric flags into logical values.  
**main actions:**
- interprets `"yes"`, `"y"`, `"true"`, `"1"` as `true`  
- interprets `"no"`, `"n"`, `"false"`, `"0"` as `false`  
- used in product `active` field and similar binary attributes  

## fx_package_size
**purpose:** parses and normalizes packaging details from the products table.  
**main actions:**
- interprets values like `12x0.5L`, `500g`, or `1kg`  
- splits them into structured columns: `pack_count`, `quantity`, and `unit`  
- standardizes units to liters (`L`) or kilograms (`kg`) for aggregation and comparison  

## general notes
- all functions are modular, composable, and null-safe.  
- they are used across all queries: products, customers, sales, returns, and shipping.  
- each function includes detailed inline comments describing transformation steps.  

📅 *last updated: october 2025*  
👩‍💻 *author: Monika Burnejko*
