// query: sales_2023
// source: sales_2023_q1, sales_2023_q2, products, customers
// purpose: merge quarterly sales datasets into a single unified table, enrich with product and customer attributes, and calculate sales_amount
// notes: removes duplicates by order_id and ensures referential integrity through left joins; used as the main fact table for analytics and dq validation
// author: Monika Burnejko | 2025

let
    // source
    quarters = {sales_2023_q1, sales_2023_q2},

    // combine all quarters
    combined = Table.Combine(quarters),

    // remove duplicates by order_id
    deduped = Table.Distinct(combined, {"order_id"}),

    // add sales amount
    sales_amount = Table.AddColumn(deduped, "sales_amount", each [quantity] * [unit_price], type number),

    // join products
    j_products = Table.NestedJoin(sales_amount, {"product_sku"}, products, {"product_sku"}, "product", JoinKind.LeftOuter),
    e_products = Table.ExpandTableColumn(j_products, "product",
        {"product_name","category","subcategory","unit_cost"},
        {"product_name","category","subcategory","unit_cost"}),

    // join customers
    j_customers = Table.NestedJoin(e_products, {"customer_id"}, customers, {"customer_id"}, "customer", JoinKind.LeftOuter),
    e_customers = Table.ExpandTableColumn(j_customers, "customer",
        {"customer_name","customer_name_ascii","email","phone","customer_country","customer_city","customer_city_ascii","segment"},
        {"customer_name","customer_name_ascii","email","phone","customer_country","customer_city","customer_city_ascii","segment"}),

    // add ascii helper for order city
    add_order_city_ascii = Table.AddColumn(e_customers, "order_city_ascii", each fx_diacritics([order_city]), type text),

    // reorder columns
    final = Table.ReorderColumns(add_order_city_ascii,
        {"order_id","order_date","customer_id","customer_name","customer_name_ascii","email","phone",
         "customer_country","customer_city","customer_city_ascii", "segment",
         "product_sku","product_name","category","subcategory","unit_cost",
         "quantity","unit_price","sales_amount","currency",
         "order_country","order_city","order_city_ascii",
         "channel","salesperson","salesperson_ascii"},
        MissingField.Ignore)
in
    final
