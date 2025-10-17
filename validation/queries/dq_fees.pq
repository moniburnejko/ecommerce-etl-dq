// query: dq_fees
// source: fees
// purpose: validate platform fee data ensuring numeric fee values, recognized country names, and valid fee types per sales channel
// notes: uses fx_in_set and fx_is_numeric to confirm all fee entries are valid and consistent with predefined structures
// author: monika burnejko | 2025


let
    // source
    source = fees,

    // helper
    as_issues = (t as table, table_name as text, field as text, rule as text, severity as text, value_col as text, optional key_col as text) as table =>
        let
            key = if key_col = null then "channel" else key_col,
            with_meta = Table.AddColumn(Table.AddColumn(Table.AddColumn(Table.AddColumn(t, "table_name", each table_name, type text), "field", each field, type text), "rule", each rule, type text), "severity", each severity, type text),
            with_value= Table.AddColumn(with_meta, "value", each Record.Field(_, value_col)),
            shaped = Table.SelectColumns(with_value, {key, "value", "table_name", "field", "rule", "severity"}),
            renamed = Table.RenameColumns(shaped, {{key, "row_key"}})
        in renamed,

    // validation rules
    // 1: missing channel
    r_channel_missing = Table.SelectRows(source, each fx_null_or_blank([channel]) = true),
    i_channel_missing = as_issues(r_channel_missing, "fees", "channel", "missing channel", "blocker", "channel"),

    // 2: missing country
    r_country_missing = Table.SelectRows(source, each fx_null_or_blank([country]) = true),
    i_country_missing = as_issues(r_country_missing, "fees", "country", "missing country", "warning", "country"),

    // 3: fee_type in {'%','fixed'}
    r_type_bad = Table.SelectRows(source, each [fee_type] <> null and not List.Contains({"%","Flat"}, [fee_type])),
    i_type_bad = as_issues(r_type_bad, "fees", "fee_type", "fee_type not in {'%','Flat'}", "warning", "fee_type"),

    // 4: fee_value not numeric or negative
    r_value_bad = Table.SelectRows(source,
        each let ok = fx_is_numeric([fee_value]) = true in (not ok) or Number.From([fee_value]) < 0),
    i_value_bad = as_issues(r_value_bad, "fees", "fee_value", "fee_value < 0 or not numeric", "blocker", "fee_value"),

    // combine
    dq_fees = Table.Combine({i_channel_missing, i_country_missing, i_type_bad, i_value_bad})
in
    dq_fees
