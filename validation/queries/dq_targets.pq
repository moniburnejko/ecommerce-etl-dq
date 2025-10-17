// query: dq_targets
// source: targets
// purpose: validate numeric values and if monthly sales targets including salesperson name
// notes: checks fx_null_or_blank for missing data, ensures numeric targets are non-null and positive
// author: monika burnejko | 2025


let
    // source
    source = targets,

    // helper
    as_issues = (t as table, table_name as text, field as text, rule as text, severity as text, value_col as text, optional key_col as text) as table =>
        let
            key = if key_col = null then "salesperson" else key_col,
            with_meta = Table.AddColumn(Table.AddColumn(Table.AddColumn(Table.AddColumn(t, "table_name", each table_name, type text), "field", each field, type text), "rule", each rule, type text), "severity", each severity, type text),
            with_value= Table.AddColumn(with_meta, "value", each Record.Field(_, value_col)),
            shaped = Table.SelectColumns(with_value, {key, "value", "table_name", "field", "rule", "severity"}),
            renamed = Table.RenameColumns(shaped, {{key, "row_key"}})
        in renamed,

    // validation rules
    // 1: salesperson present
    r_salesperson_missing = Table.SelectRows(source, each fx_null_or_blank([salesperson]) = true),
    i_salesperson_missing = as_issues(r_salesperson_missing, "targets", "salesperson", "missing salesperson", "blocker", "salesperson"),

    // 2: target_value numeric and non-negative
    r_target_value_bad = Table.SelectRows(source, each fx_is_numeric([target_value]) <> true or Number.From([target_value]) < 0),
    i_target_value_bad = as_issues(r_target_value_bad, "targets", "target_value", "target_value < 0 or not numeric", "blocker", "target_value"),

    // combine
    dq_targets = Table.Combine({ i_salesperson_missing, i_target_value_bad})
in
    dq_targets
