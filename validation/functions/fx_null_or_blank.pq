// function: fx_null_or_blank
// purpose: check if a value is null, empty, or whitespace-only and return true/false
// notes: used in validation rules to detect missing or invalid fields
// author: monika burnejko | 2025

 let
    fx_null_or_blank=(x as any) as logical =>
    let
        res=
            if x=null then true
            else if Value.Is(x,type text) then Text.Trim(Text.From(x))=""
            else false
    in
        res
in
    fx_null_or_blank