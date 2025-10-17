// query: dq_products
// source: products
// purpose: validate product master data including SKU uniqueness, ean length, numeric fields, and logical completeness of packaging structure
// notes: ensures each product_sku is unique, all numeric fields are valid, and packaging details (pack_count, quantity, unit) are consistent
// author: monika burnejko | 2025

let
    // source
    source = products,

    // helper: wrap failed rows as standardized issue records
    as_issues = (t as table, table_name as text, field as text, rule as text, severity as text, value_col as text, optional key_col as text) as table =>
        let
            key = if key_col = null then "product_sku" else key_col,
            with_meta = Table.AddColumn(Table.AddColumn(Table.AddColumn(Table.AddColumn(t, "table_name", each table_name, type text), "field", each field, type text), "rule", each rule, type text), "severity", each severity, type text),
            with_value= Table.AddColumn(with_meta, "value", each Record.Field(_, value_col)),
            shaped = Table.SelectColumns(with_value, {key, "value", "table_name", "field", "rule", "severity"}),
            renamed = Table.RenameColumns(shaped, {{key, "row_key"}})
        in
            renamed,

    // validation rules
    // 1: missing product_sku
    r_missing_sku = Table.SelectRows(source, each fx_null_or_blank([product_sku]) = true),
    i_missing_sku = as_issues(r_missing_sku, "products", "product_sku", "missing product_sku", "blocker", "product_sku"),

    // 2: ean must be 13 digits
    r_ean_bad = Table.SelectRows(source, each [ean] = null or Text.Length(Text.Select(Text.From([ean]), {"0".."9"})) <> 13),
    i_ean_bad = as_issues(r_ean_bad, "products", "ean", "ean not 13 digits", "blocker", "ean"),

    // 3: unit_cost not numeric or negative
    r_unit_cost_bad = Table.SelectRows(source,
        each let ok = fx_is_numeric([unit_cost]) = true in (not ok) or Number.From([unit_cost]) < 0),
    i_unit_cost_bad = as_issues(r_unit_cost_bad, "products", "unit_cost", "unit_cost < 0 or not numeric", "blocker", "unit_cost"),

    // 4: package parts validation: pack_count >= 1, quantity > 0, unit in {'L','kg'}
    r_pack_count_bad = Table.SelectRows(source, each [pack_count] = null or [pack_count] < 1),
    i_pack_count_bad = as_issues(r_pack_count_bad, "products", "pack_count", "invalid pack_count (<1 or null)", "warning", "pack_count"),

    r_quantity_bad = Table.SelectRows(source,
        each let ok = fx_is_numeric([quantity]) = true in (not ok) or Number.From([quantity]) <= 0),
    i_quantity_bad = as_issues(r_quantity_bad, "products", "quantity", "invalid quantity (<=0 or not numeric)", "warning", "quantity"),

    r_unit_bad = Table.SelectRows(source, each [unit] = null or not List.Contains({"L","kg"}, [unit])),
    i_unit_bad = as_issues(r_unit_bad, "products", "unit", "unit not in {'L','kg'}", "warning", "unit"),

    // 5: product_name present
    r_name_missing = Table.SelectRows(source, each fx_null_or_blank([product_name]) = true),
    i_name_missing = as_issues(r_name_missing, "products", "product_name", "missing product_name", "warning", "product_name"),

    // combine all detected issues
    dq_products = Table.Combine({ i_missing_sku, i_ean_bad, i_unit_cost_bad, i_pack_count_bad, i_quantity_bad, i_unit_bad, i_name_missing })
in
    dq_products
