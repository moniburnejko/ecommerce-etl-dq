// query: shipping
// source: /data/sales_2023_raw.xlsx [Shipping sheet]
// purpose: clean and standardize shipping records, split composite fields, and validate delivery cost and estimated time
// notes: splits shippinginfo into carrier, delivery_type, and estimated_delivery_days; standardizes text and numeric values
// author: monika burnejko | 2025

let
    // source & headers
    source = Excel.Workbook(File.Contents("data/sales_2023_raw.xlsx"), null, true),
    nav = source{[Item = "Shipping", Kind = "Sheet"]}[Data],
    headers = Table.PromoteHeaders(nav, [PromoteAllScalars = true]),

    // generic cleaning
    clean = fx_clean(headers),

    // split shipping info into 3 columns
    split = Table.SplitColumn(
        clean,
        "shippinginfo",
        Splitter.SplitTextByDelimiter("|", QuoteStyle.Csv),
        {"carrier","delivery_type","estimated_delivery_days"}),

    // rename columns
    renamed = Table.RenameColumns(split, {{"orderid","order_id"},{"costpln","cost_pln"}}),

    // validate numeric fields
    num_fixed = Table.TransformColumns(renamed, {{"cost_pln", each try fx_number(_) otherwise null, type number}}),

    // text columns transforms 
    text_fixed = Table.TransformColumns(num_fixed,
        {{"order_id", each fx_text(_), type text},
        {"carrier", each fx_text(_, "none"), type text},
        {"delivery_type", each fx_text(_), type text},
        {"address", each fx_text(_, "none"), type text}}),

    // clean delivery days column by removing "d" and spaces
    days_clean = Table.TransformColumns(text_fixed,
        {{"estimated_delivery_days", each 
            if _ = null then null 
            else Text.Replace(Text.Replace(Text.Upper(_), "D", ""), " ", ""), type text}}),

    // final order
    reordered = Table.ReorderColumns(
        days_clean,
        {"order_id","carrier","delivery_type","estimated_delivery_days","cost_pln","address"},
        MissingField.Ignore),

    // deduplicate by order_id
    deduped = Table.Distinct(reordered, {"order_id"})
in
    deduped
