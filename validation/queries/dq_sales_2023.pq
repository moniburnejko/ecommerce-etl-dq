// query: dq_sales_2023
// source: sales_2023
// purpose: validate core transactional data integrity including key completeness, numeric consistency, currency validation, date ranges, and foreign key relations with products and customers
// notes: leverages fx_null_or_blank, fx_is_numeric, fx_is_between, and fx_in_set; ensures 2023-only transactions and cross-table consistency
// author: monika burnejko | 2025

let
    // source
    source = sales_2023,

    // reference lists
    product_keys = List.Buffer(Table.Column(products, "product_sku")),
    customer_keys = List.Buffer(Table.Column(customers, "customer_id")),
    allowed_currency = {"PLN","EUR","USD"},

    // helper: wrap failed rows as standardized issue records
    as_issues = (t as table, table_name as text, field as text, rule as text, severity as text, value_col as text, optional key_col as text) as table =>
        let
            key = if key_col = null then "order_id" else key_col,
            with_meta = Table.AddColumn(
                          Table.AddColumn(
                            Table.AddColumn(
                              Table.AddColumn(t, "table_name", each table_name, type text),
                            "field", each field, type text),
                          "rule", each rule, type text),
                        "severity", each severity, type text),
            // include the invalid value and a row key identifier
            with_value = Table.AddColumn(with_meta, "value", each Record.Field(_, value_col)),
            shaped = Table.SelectColumns(with_value, {key, "value", "table_name", "field", "rule", "severity"}),
            renamed = Table.RenameColumns(shaped, {{key, "row_key"}})
        in
            renamed,

    // validation rules
    // 1: missing or blank order id (null treated as failure)
    r_missing_order_id = Table.SelectRows(source, each fx_null_or_blank([order_id]) = true),
    i_missing_order_id = as_issues(r_missing_order_id, "sales_2023", "order_id", "missing order_id", "blocker", "order_id"),

    // 2: invalid currency (not in allowed list; null = failure)
    r_currency_bad = Table.SelectRows(source, each fx_in_set([currency], allowed_currency) <> true),
    i_currency_bad = as_issues(r_currency_bad, "sales_2023", "currency", "currency not allowed", "blocker", "currency"),

    // 3: unit_price not numeric or negative
    r_unit_price_bad = Table.SelectRows(source,
        each
            let
                is_num = fx_is_numeric([unit_price]) = true,
                is_neg = if is_num then Number.From([unit_price]) < 0 else true
            in
                (not is_num) or is_neg),
    i_unit_price_bad = as_issues(r_unit_price_bad, "sales_2023", "unit_price", "unit_price < 0 or not numeric", "blocker", "unit_price"),

    // 4: quantity not numeric or < 1
    r_quantity_bad =Table.SelectRows(source,
        each
            let
                is_num = fx_is_numeric([quantity]) = true,
                too_low = if is_num then Number.From([quantity]) < 1 else true
            in
                (not is_num) or too_low),
    i_quantity_bad = as_issues(r_quantity_bad, "sales_2023", "quantity", "quantity < 1 or not numeric", "blocker", "quantity"),

    // 5: product fk: sku not in products (null = failure)
    r_product_fk = Table.SelectRows(source, each fx_in_set([product_sku], product_keys) <> true),
    i_product_fk = as_issues(r_product_fk, "sales_2023", "product_sku", "product not found in products", "blocker", "product_sku"),

    // 6: customer fk: id not in customers (null = failure)
    r_customer_fk = Table.SelectRows(source, each fx_in_set([customer_id], customer_keys) <> true),
    i_customer_fk = as_issues(r_customer_fk, "sales_2023", "customer_id", "customer not found in customers", "blocker", "customer_id"),

    // 7: order_date outside 2023 (null = failure)
    r_order_date_bad = Table.SelectRows(source, each fx_is_between([order_date], #date(2023,1,1), #date(2023,12,31)) <> true),
    i_order_date_bad = as_issues(r_order_date_bad, "sales_2023", "order_date", "order_date outside 2023", "blocker", "order_date"),

    // combine all detected issues
    dq_sales_2023 = Table.Combine({i_missing_order_id, i_currency_bad, i_unit_price_bad, i_quantity_bad, i_product_fk, i_customer_fk,i_order_date_bad})
in
    dq_sales_2023
