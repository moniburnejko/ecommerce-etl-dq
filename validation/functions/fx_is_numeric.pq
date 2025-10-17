// function: fx_is_numeric
// purpose: verify whether a given value can be safely converted to a number
// notes: ensures numeric consistency before arithmetic or type conversions
// author: monika burnejko | 2025

let
    fx_is_numeric=(x as any) as logical =>
    let
        n=try Number.From(x) otherwise null,
        res=n<>null
    in
        res
in
    fx_is_numeric