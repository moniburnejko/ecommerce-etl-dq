// query: sales_2023_q2
// source: /data/sales_2023_raw.xlsx [Sales_2023_Q2 sheet]
// purpose: clean and standardize q2 transactional data, align schema with q1 dataset for later merging
// notes: applies text, numeric, date, and country standardization, and adds ascii helper for salesperson
// author: monika burnejko | 2025

let
    // source & headers
    source = Excel.Workbook(File.Contents("data/sales_2023_raw.xlsx"), null, true),
    nav = source{[Item = "Sales_2023_Q2", Kind = "Sheet"]}[Data],
    headers = Table.PromoteHeaders(nav, [PromoteAllScalars = true]),

    // generic cleaning
    clean = fx_clean(headers),

    // rename columns
    renamed = Table.RenameColumns(clean,
        {{"date","order_date"}, {"custid","customer_id"}, {"sku","product_sku"},
         {"price","unit_price"}, {"curr","currency"}, {"country_name","order_country"},
         {"city","order_city"}, {"rep","salesperson"}}),

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
    salesperson_clean = Table.TransformColumns(curr, {"salesperson", each if _ = "-" or _ = "–" then null else _}),

    // add ascii helper column for salesperson
    add_salesperson_ascii = Table.AddColumn(salesperson_clean, "salesperson_ascii", each fx_diacritics([salesperson]), type text),

    // reorder columns
    reordered = Table.ReorderColumns(add_salesperson_ascii,
        {"order_id","order_date","customer_id","product_sku","quantity","unit_price","currency",
         "order_country","order_city","channel","salesperson","salesperson_ascii"}),

    // remove duplicates (based on order_id)
    deduped = Table.Distinct(reordered, {"order_id"})
in
    deduped
