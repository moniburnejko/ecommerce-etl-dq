// query: products
// source: /data/sales_2023_database_raw.xlsx [Products sheet]
// purpose: clean and standardize product master data, validate numeric cost fields, and parse package size into structured components
// notes: expands fx_package_size into separate columns (pack_count, quantity, unit) and normalizes product_name formatting
// author: Monika Burnejko | 2025

let
    // source & headers
    source = Excel.Workbook(File.Contents("data/sales_2023_database_raw.xlsx"), null, true),
    nav = source{[Item = "Products", Kind = "Sheet"]}[Data],
    headers = Table.PromoteHeaders(nav, [PromoteAllScalars = true]),

    // generic cleaning
    clean = fx_clean(headers),

    // rename columns
    renamed = Table.RenameColumns(clean,
        {{"sku","product_sku"}, {"productname","product_name"},
         {"unitcost","unit_cost"}, {"packagesize","package_size"}}),

    // fix data entry errors (replace "1" → "i" in product_name)
    fix_values = Table.ReplaceValue(renamed, "1", "i", Replacer.ReplaceText, {"product_name"}),

    // remove symbols (product_name)
    remove_symbols = Table.TransformColumns(fix_values, {"product_name", each Text.Remove(_, {"™","®","©","℗"})}),

    // standardize text columns
    text_cols  = {"product_sku","product_name","category","subcategory","supplier", "ean"},
    text_fixed = Table.TransformColumns(remove_symbols, List.Transform(text_cols, (c) => {c, each fx_text(_), type text})),

    // spelling normalization (BBQ in product_name)
    product_name_final = Table.TransformColumns(text_fixed,
        {{"product_name", each Text.Replace(Text.Replace(_, "Bbq", "BBQ"), "bbq", "BBQ")}}),

    // validate numeric fields
    num_fixed = Table.TransformColumns(product_name_final,
        {{"unit_cost", each fx_number(_), type number}}),

    // normalize logical column
    logical_fixed = Table.TransformColumns(num_fixed,
        {{"active", each fx_logical(_), type logical}}),

    // parse package_size and expand to 3 columns
    package_record = Table.AddColumn(logical_fixed, "package_size_parts", each fx_package_size([package_size]), type record),
    package_expanded = Table.ExpandRecordColumn(package_record, "package_size_parts",
        {"pack_count","quantity","unit"}, {"pack_count","quantity","unit"}),

    // remove original package_size column
    remove_package_size = Table.RemoveColumns(package_expanded, {"package_size"}),

    // change column types
    typed = Table.TransformColumnTypes(remove_package_size,
        {{"pack_count", Int64.Type}, {"quantity", type number}, {"unit", type text}}),

    // reorder columns
    reordered = Table.ReorderColumns(typed,
        {"product_sku","product_name","category","subcategory","unit_cost",
         "pack_count","quantity","unit","ean","active","supplier"}),

    // deduplicate
    deduped = Table.Distinct(reordered)
in
    deduped
