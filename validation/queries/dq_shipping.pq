// query: dq_shipping
// source: shipping
// purpose: validate shipping data including order linkage and cost field accuracy
// notes: verifies each order_id exists in sales_2023, ensures cost_pln is numeric and positive
// author: monika burnejko | 2025


let
    // source
    source = shipping,
    order_keys = List.Buffer(Table.Column(sales_2023, "order_id")),

    // helper
    as_issues = (t as table, table_name as text, field as text, rule as text, severity as text, value_col as text, optional key_col as text) as table =>
        let
            key = if key_col = null then "order_id" else key_col,
            with_meta = Table.AddColumn(Table.AddColumn(Table.AddColumn(Table.AddColumn(t, "table_name", each table_name, type text), "field", each field, type text), "rule", each rule, type text), "severity", each severity, type text),
            with_value= Table.AddColumn(with_meta, "value", each Record.Field(_, value_col)),
            shaped = Table.SelectColumns(with_value, {key, "value", "table_name", "field", "rule", "severity"}),
            renamed = Table.RenameColumns(shaped, {{key, "row_key"}})
        in renamed,

    // validation rules
    // 1: missing order_id
    r_missing_order_id = Table.SelectRows(source, each fx_null_or_blank([order_id]) = true),
    i_missing_order_id = as_issues(r_missing_order_id, "shipping", "order_id", "missing order_id", "blocker", "order_id"),

    // 2: order_id in shipping exist in sales_2023
    r_order_fk = Table.SelectRows(source, each [order_id] <> null and not List.Contains(order_keys, [order_id])),
    i_order_fk = as_issues(r_order_fk, "shipping", "order_id", "order_id not found in sales_2023", "blocker", "order_id"),

    // 3: cost_pln not numeric or negative
    r_cost_bad = Table.SelectRows(source,
        each let ok = fx_is_numeric([cost_pln]) = true in (not ok) or Number.From([cost_pln]) < 0),
    i_cost_bad = as_issues(r_cost_bad, "shipping", "cost_pln", "cost_pln < 0 or not numeric", "warning", "cost_pln"),

    // 4: address present
    r_address_missing = Table.SelectRows(source, each fx_null_or_blank([address]) = true),
    i_address_missing = as_issues(r_address_missing, "shipping", "address", "missing address", "info", "address"),

    // combine
    dq_shipping = Table.Combine({i_missing_order_id, i_order_fk, i_cost_bad, i_address_missing})
in
    dq_shipping
