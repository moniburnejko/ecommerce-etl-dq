// query: returns
// source: /data/sales_2023_raw.xlsx [Returns sheet]
// purpose: clean and standardize product return records, including return dates, linked order id, and reason codes
// notes: applies fx_date and fx_text normalization, renames columns, and removes duplicates by return_id
// author: monika burnejko | 2025

let
    // source & headers
    source = Excel.Workbook(File.Contents("data/sales_2023_raw.xlsx"), null, true),
    nav = source{[Item = "Returns", Kind = "Sheet"]}[Data],
    headers = Table.PromoteHeaders(nav, [PromoteAllScalars = true]),

    // generic cleaning
    clean = fx_clean(headers),

    // standardize date column
    date_fixed = Table.TransformColumns(clean, {{"date", each fx_date(_), type date}}),

    // standardize text columns
    text_cols = {"returnid","orderid","reason","status"},
    text_fixed = Table.TransformColumns(date_fixed, List.Transform(text_cols, (c) => {c, each fx_text(_), type text})),

    // rename columns
    renamed = Table.RenameColumns(text_fixed,
      {{"returnid","return_id"}, {"date","return_date"}, {"orderid","order_id"}}),

    // reorder columns
    reordered = Table.ReorderColumns(renamed, {"return_id","return_date","order_id","reason","status"}, MissingField.Ignore),

    // remove duplicates by return_id
    deduped = Table.Distinct(reordered, {"return_id"})
in
    deduped
