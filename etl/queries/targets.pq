// query: targets
// source: /data/sales_2023_raw.xlsx [Targets_Wide sheet]
// purpose: transform wide-format sales targets into a tidy structure, converting month columns to rows and parsing numeric target values
// notes: derives month_number from month name, adds ascii helper for salesperson, and ensures correct data typing
// author: monika burnejko | 2025

let
    // source & headers
    source = Excel.Workbook(File.Contents("data/sales_2023_raw.xlsx"), null, true),
    nav = source{[Item = "Targets_Wide", Kind = "Sheet"]}[Data],
    headers = Table.PromoteHeaders(nav, [PromoteAllScalars = true]),

    // generic cleaning
    clean = fx_clean(headers),

    // unpivot columns, keeping non-target columns
    unpivoted = Table.UnpivotOtherColumns(clean, {"salesperson","note"}, "month", "target_value"),

    // standardize text columns
    text_fixed = Table.TransformColumns(unpivoted,
        {{"salesperson", each fx_text(_), type text},
        {"month", each fx_text(_), type text},
        {"note", each fx_text(_, "none"), type text}}),

    // validate numeric fields
    num_fixed = Table.TransformColumns(text_fixed, {{"target_value", each try fx_number(_) otherwise null, type number}}),

    // derive month number from month name
    add_month_number = Table.AddColumn(num_fixed, "month_number",
        each Date.Month(Date.FromText("2023-" & [month] & "-01", "en-US")), Int64.Type),

    // add ascii helper column for salesperson
    add_ascii = Table.AddColumn(add_month_number, "salesperson_ascii", each fx_diacritics([salesperson]), type text),

    // reorder columns
    reordered = Table.ReorderColumns(add_ascii, {"salesperson","salesperson_ascii","month","month_number","target_value","note"}),

    // remove duplicates
    deduped = Table.Distinct(reordered)
in
    deduped
