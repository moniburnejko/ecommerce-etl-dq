// query: customers
// source: /data/sample/sales_2023_raw.xlsx [Customers sheet]
// purpose: clean and standardize customer master data including id, contact info, location, and join dates
// notes: normalizes email and phone formats, applies fx_country and fx_diacritics, and adds ascii helper columns
// author: monika burnejko | 2025

let
    // source & headers
    source = Excel.Workbook(File.Contents("data/sample/sales_2023_raw.xlsx"), null, true),
    nav = source{[Item = "Customers", Kind = "Sheet"]}[Data],
    headers = Table.PromoteHeaders(nav, [PromoteAllScalars = true]),

    // generic cleaning
    clean = fx_clean(headers),

    // rename columns
    renamed = Table.RenameColumns(clean,
        {{"customerid","customer_id"}, {"customername","customer_name"},
         {"country","customer_country"}, {"city","customer_city"}, {"joindate", "join_date"}),

    // standardize text columns
    text_fixed = Table.TransformColumns(renamed, 
    {{"customer_id", each fx_text(_), type text},
    {"customer_name", each fx_text(_), type text},
    {"customer_city", each fx_text(_), type text},
    {"segment", each fx_text(_, "none"), type text},
    {"vat", each fx_text(_, "upper"), type text}}),

    // email normalization (lowercase + remove diacritics)
    email_norm = Table.TransformColumns(text_fixed,
        {{"email", each if _ = null then null else fx_diacritics(Text.Lower(_)), type text}}),

    // phone normalization (keep digits and leading +)
    phone_norm = Table.TransformColumns(email_norm,
        {{"phone", each 
            if _ = null then null 
            else 
                let
                    digits = Text.Select(_, {"0".."9","+"}),
                    result = if Text.StartsWith(digits, "+") 
                             then "+" & Text.Select(Text.Range(digits,1), {"0".."9"})
                             else Text.Select(digits, {"0".."9"})
                in result, type text}}),

    // country standardization
    country_fixed = Table.TransformColumns(phone_norm, {{"customer_country", each fx_country(_), type text}}),

    // date standardization
    date_fixed = Table.TransformColumns(country_fixed, {{"join_date", each fx_date(_), type date}}),

    // add ascii helper columns
    add_ascii = Table.AddColumn(date_fixed, "customer_name_ascii", each fx_diacritics([customer_name]), type text),
    add_ascii_city = Table.AddColumn(add_ascii, "customer_city_ascii", each fx_diacritics([customer_city]), type text),

    // reorder columns
    reordered = Table.ReorderColumns(add_ascii_city,
        {"customer_id","customer_name","customer_name_ascii","email","phone",
         "customer_country","customer_city","customer_city_ascii",
         "segment","vat","join_date"}),

    // deduplicate full rows
    deduped = Table.Distinct(reordered)
in
    deduped
