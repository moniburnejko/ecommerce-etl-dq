// function: fx_logical
// purpose: convert various textual or numeric boolean representations into logical (true/false)
// notes: supports yes/no, y/n, 1/0, and true/false variants
// author: monika burnejko | 2025

let
    fx_logical = (x as nullable any) as nullable logical =>
    let
        // handle nulls and normalize input to uppercase text
        input_text = if x = null then null else Text.Upper(Text.Trim(Text.From(x))),

        // map common true / false values
        result =
            if input_text = null then null
            else if List.Contains({"YES","Y","TRUE","1"}, input_text) then true
            else if List.Contains({"NO","N","FALSE","0"}, input_text) then false
            else null
    in
        result
in
    fx_logical