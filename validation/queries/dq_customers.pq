// query: dq_customers
// source: customers
// purpose: validate customer master data including key completeness, email and phone format, and country normalization
// notes: uses fx_null_or_blank to ensure all customers have valid ids
// author: monika burnejko | 2025

let
    // source
    source = customers,

    // helper
    as_issues = (t as table, table_name as text, field as text, rule as text, severity as text, value_col as text, optional key_col as text) =>
        let
            key = if key_col = null then "customer_id" else key_col,
            with_meta = Table.AddColumn(
                Table.AddColumn(
                    Table.AddColumn(
                        Table.AddColumn(t, "table_name", each table_name, type text),
                        "field", each field, type text),
                    "rule", each rule, type text),
                "severity", each severity, type text),
            with_value = Table.AddColumn(with_meta, "value", each Record.Field(_, value_col)),
            shaped = Table.SelectColumns(with_value, {key, "value", "table_name", "field", "rule", "severity"}),
            renamed = Table.RenameColumns(shaped, {{key, "row_key"}})
        in
            renamed,
    // validation rules
    // 1: missing customer_id
    r_missing_id = Table.SelectRows(source, each fx_null_or_blank([customer_id]) = true),
    i_missing_id = as_issues(r_missing_id, "customers", "customer_id", "missing customer_id", "blocker", "customer_id"),

    // 2: missing customer_name
    r_missing_name = Table.SelectRows(source, each fx_null_or_blank([customer_name]) = true),
    i_missing_name = as_issues(r_missing_name, "customers", "customer_name", "missing customer_name", "warning", "customer_name"),

    // 3: invalid email (very simple check)
    r_email_bad = Table.SelectRows(source, each [email] <> null and not Text.Contains([email], "@")),
    i_email_bad = as_issues(r_email_bad, "customers", "email", "invalid email format", "warning", "email"),

    // 4: phone too short (< 9 digits after cleaning)
    r_phone_short = Table.SelectRows(source, each [phone] <> null and Text.Length(Text.Select([phone], {"0".."9"})) < 9),
    i_phone_short = as_issues(r_phone_short, "customers", "phone", "phone too short", "warning", "phone"),

    // 5: missing country
    r_country_missing = Table.SelectRows(source, each fx_null_or_blank([customer_country]) = true),
    i_country_missing = as_issues(r_country_missing, "customers", "customer_country", "missing customer_country", "warning", "customer_country"),

    // combine
    dq_customers = Table.Combine({ i_missing_id, i_missing_name, i_email_bad, i_phone_short, i_country_missing})
in
    dq_customers
