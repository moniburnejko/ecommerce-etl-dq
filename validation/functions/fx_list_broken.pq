// function: fx_list_broken
// purpose: collect the names of validation rules that failed (evaluated to false) within a record
// notes: used in rule-based dq audits to identify all failed checks per row
// author: monika burnejko | 2025

let
    fx_list_broken=(row as record) as list =>
    let
        names=Record.FieldNames(row),
        ruleNames=List.Select(names, each Text.StartsWith(_, "rule_")),
        broken=List.Select(ruleNames, each Record.Field(row, _) = false)
    in
        broken
in
    fx_list_broken