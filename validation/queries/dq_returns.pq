// query: dq_returns
// source: returns
// purpose: validate return transaction data including key presence, link to existing orders, and valid date sequence (return_date > order_date)
// notes: uses fx_is_between and relational check against sales_2023 to ensure returns are matched and dated correctly
// author: monika burnejko | 2025

let
    // source
    source = returns,
    order_keys = List.Buffer(Table.Column(sales_2023, "order_id")),

    // helper
    as_issues = (t as table, table_name as text, field as text, rule as text, severity as text, value_col as text, optional key_col as text) as table =>
        let
            key = if key_col = null then "return_id" else key_col,
            with_meta = Table.AddColumn(Table.AddColumn(Table.AddColumn(Table.AddColumn(t, "table_name", each table_name, type text), "field", each field, type text), "rule", each rule, type text), "severity", each severity, type text),
            with_value= Table.AddColumn(with_meta, "value", each Record.Field(_, value_col)),
            shaped = Table.SelectColumns(with_value, {key, "value", "table_name", "field", "rule", "severity"}),
            renamed = Table.RenameColumns(shaped, {{key, "row_key"}})
        in renamed,

    // validation rules
    // 1: missing return_id
    r_missing_id = Table.SelectRows(source, each fx_null_or_blank([return_id]) = true),
    i_missing_id = as_issues(r_missing_id, "returns", "return_id", "missing return_id", "blocker", "return_id"),

    // 2: return_date outside 2023 (null = failure)
    r_date_bad = Table.SelectRows(source, each fx_is_between([return_date], #date(2023,1,1), #date(2023,12,31)) <> true),
    i_date_bad = as_issues(r_date_bad, "returns", "return_date", "return_date outside 2023", "warning", "return_date"),

    // 3: missing or invalid order_id (fk to sales_2023)
    r_order_missing = Table.SelectRows(source, each fx_null_or_blank([order_id]) = true or not List.Contains(order_keys, [order_id])),
    i_order_missing = as_issues(r_order_missing, "returns", "order_id", "order_id missing or not found in sales_2023", "blocker", "order_id"),

    // 4: return_date before order_date (invalid)
    // join to get order_date for same order_id
    joined = Table.NestedJoin(source, {"order_id"}, sales_2023, {"order_id"}, "order_row", JoinKind.LeftOuter),
    expanded = Table.ExpandTableColumn(joined, "order_row", {"order_date"}, {"order_date"}),

    r_return_before_order = Table.SelectRows(expanded, each [return_date] <> null and [order_date] <> null and [return_date] < [order_date]),
    i_return_before_order = as_issues(r_return_before_order, "returns", "return_date", "return_date earlier than order_date", "blocker", "return_date"),

    // combine
    dq_returns = Table.Combine({i_missing_id, i_date_bad, i_order_missing, i_return_before_order})
in
    dq_returns
