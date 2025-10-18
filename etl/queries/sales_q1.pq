// query: sales_2023_q1
// source: /data/sample/sales_2023_raw.xlsx [Sales_2023_Q1 sheet]
// purpose: clean and standardize q1 transactional data, normalize column names, data types, and ensure consistency across key fields
// notes: used as base input for sales_2023; applies text, numeric, date, and country standardization
// author: monika burnejko | 2025

let
    // source & headers
    source = Excel.Workbook(File.Contents("data/sample/sales_2023_raw.xlsx"), null, true),
    nav = source{[Item = "Sales_2023_Q1", Kind = "Sheet"]}[Data],
    headers = Table.PromoteHeaders(nav, [PromoteAllScalars = true]),

    // generic cleaning
    clean = fx_clean(headers),

    // rename columns
    renamed = Table.RenameColumns(clean,
        {{"orderid","order_id"}, {"orderdate","order_date"}, {"customerid","customer_id"},
         {"productsku","product_sku"}, {"qty","quantity"}, {"unitprice","unit_price"},
         {"country","order_country"}, {"city","order_city"}}),

    // parse dates
    date_fixed = Table.TransformColumns(renamed, {{"order_date", each try fx_date(_) otherwise null, type date}}),

    // validate numeric fields
    num_fixed = Table.TransformColumns(date_fixed, 
    {{"quantity", each try fx_number(_) otherwise null, Int64.Type},
    {"unit_price", each try fx_number(_) otherwise null, type number}}),

    // standardize country names
    country_fixed = Table.TransformColumns(num_fixed, {{"order_country", each fx_country(_), type text}}),

    // standardize text columns
    text_cols = {"order_id","customer_id","product_sku","order_city","salesperson","channel"},
    text_fixed  = Table.TransformColumns(country_fixed, List.Transform(text_cols, (c) => {c, each fx_text(_), type text})),
    curr = Table.TransformColumns(text_fixed, {"currency", each fx_text(_, "upper"), type text}),

    // add ascii helper column for salesperson
    add_salesperson_ascii = Table.AddColumn(curr, "salesperson_ascii", each fx_diacritics([salesperson]), type text),

    // reorder columns
    reordered = Table.ReorderColumns(add_salesperson_ascii,
        {"order_id","order_date","customer_id","product_sku","quantity","unit_price","currency",
         "order_country","order_city","channel","salesperson","salesperson_ascii"}),

    // remove duplicates (based on order_id)
    deduped = Table.Distinct(reordered, {"order_id"})
in
    deduped
