// query: dq_summary
// source: all dq_* queries
// purpose: aggregate data quality findings from all dq_* tables into a unified summary view for monitoring completeness and error distribution
// notes: consolidates validation outputs into a single table with counts by table, field, rule, and severity
// author: monika burnejko | 2025

let
    // source dq tables
    dq_tables = {
        dq_sales_2023,
        dq_returns,
        dq_shipping,
        dq_products,
        dq_customers,
        dq_targets,
        dq_fees},

    // combine all dq issues into one table
    dq_combined = Table.Combine(dq_tables),

    // ensure consistent column types
    typed = Table.TransformColumnTypes(dq_combined,
      {{"table_name", type text}, {"field", type text}, {"rule", type text},
       {"severity", type text}, {"row_key", type text}}),

    // aggregate summary by table, field, rule and severity
    grouped = Table.Group(typed,
      {"table_name","field","rule","severity"},
      {{"issue_count", each Table.RowCount(_), Int64.Type}}),

    // summary per table: total issues + blocker count
    summary_by_table = Table.Group(grouped,
      {"table_name"},
      {{"total_issues", each List.Sum([issue_count]), Int64.Type},
      {"blockers", each List.Sum(List.Transform(Table.SelectRows(_, each [severity] = "blocker")[issue_count], each _)), Int64.Type}}),

    // compute dq score
    with_score = Table.AddColumn(summary_by_table, "dq_score",
      each Number.Round(100 - ([blockers] * 2 + [total_issues] * 1) * 100.0 / ( [total_issues] + 10 ), 2)),

    // reorder and format
    final = Table.ReorderColumns(with_score, {"table_name","total_issues","blockers","dq_score"})
in
    final
