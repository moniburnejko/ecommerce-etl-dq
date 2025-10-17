// function: fx_clean
// purpose: remove empty rows, trim all text fields, and normalize column headers to lowercase snake_case
// notes: applied at the start of each query to ensure consistent schema and clean data structure
// author: monika burnejko | 2025

let
    fx_clean=(t as table) as table =>
    let
        // remove fully empty rows
        remove_empty_rows=Table.SelectRows(t,each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_),{"",null}))),

        // trim text cells
        trimmed_cells=Table.TransformColumns(
            remove_empty_rows,
            List.Transform(Table.ColumnNames(remove_empty_rows),(c)=>{c,(x)=>if x is text then Text.Trim(x) else x,type any})
        ),

        // helper: slug -> lowercase snake_case (no '#', '-', ' ', '.')
        slug=(s as text) as text =>
            let
                s0=Text.Lower(Text.Trim(s)),
                repl={{"#","no"},{"-","_"},{" ","_"},{".","_"}},
                s1=List.Accumulate(repl,s0,(acc,p)=>Text.Replace(acc,p{0},p{1})),
                tokens=List.Select(Text.Split(s1,"_"),each _<>""),
                s2=Text.Combine(tokens,"_")
            in s2,

        // normalize single column name
        normalize_name=(name as text) as text =>
            let
                n0=Text.Trim(name),
                // payload inside first parentheses (optional)
                payload=if Text.Contains(n0,"(") and Text.Contains(n0,")") then Text.BetweenDelimiters(n0,"(",")",Occurrence.First) else null,
                // base without parentheses
                base_no_parens=Text.Replace(Text.Replace(n0,"(",""),")",""),
                base_slug=slug(base_no_parens),
                payload_slug=if payload=null then null else slug(payload),
                base_parts=Text.Split(base_slug,"_"),
                last_token=if List.Count(base_parts)>0 then List.Last(base_parts) else base_slug,
                with_payload=if payload_slug=null or payload_slug="" or payload_slug=last_token then base_slug else base_slug&"_"&payload_slug,
                final_name=Text.Trim(with_payload,"_")
            in final_name,

        // apply to headers
        renamed_cols=Table.TransformColumnNames(trimmed_cells,each normalize_name(_))
    in
        renamed_cols
in
    fx_clean