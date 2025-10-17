// query: fees
// source: /data/sample/sales_2023_raw.xlsx [Fees sheet]
// purpose: clean and standardize sales fee data including channel, country, fee_type, and fee_value fields
// notes: applies fx_country, fx_number, and fx_text functions, enforces schema consistency, and deduplicates by channel-country-fee_type
// author: Monika Burnejko | 2025

let
    // source & headers
    source  = Excel.Workbook(File.Contents("data/sample/sales_2023_raw.xlsx"), null, true),
    nav = source{[Item = "Fees", Kind = "Sheet"]}[Data],
    headers = Table.PromoteHeaders(nav, [PromoteAllScalars = true]),

    // generic cleaning
    clean = fx_clean(headers),

    // standardize text columns
    text_cols = {"channel","feetype"},
    text_fixed = Table.TransformColumns(clean, List.Transform(text_cols, (c) => {c, each fx_text(_), type text})),

    // validate numeric fields
    num_fixed = Table.TransformColumns(text_fixed, {"feevalue", each try fx_number(_) otherwise null, type number}),

    // country standardization
    country_fixed  = Table.TransformColumns(num_fixed, {{"country", each fx_country(_), type text}}),

    // rename + order
    renamed = Table.RenameColumns(country_fixed, {{"feetype","fee_type"}, {"feevalue","fee_value"}}),
    reordered = Table.ReorderColumns(renamed, {"channel","country","fee_type","fee_value"}, MissingField.Ignore),

    // deduplicate
    deduped = Table.Distinct(reordered, {"channel","country","fee_type"})
in
    deduped
