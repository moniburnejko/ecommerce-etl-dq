// function: fx_diacritics
// purpose: remove Polish and other Latin diacritics from text to create ascii-safe versions
// notes: used for helper columns (e.g., customer_name_ascii, city_ascii) to improve joins and search
// author: monika burnejko | 2025

let
    fx_diacritics = (x as nullable text) as nullable text =>
    let
        // handle null values
        input_text = if x = null then null else Text.From(x),

        // mapping of characters to replacements
        replace_pairs = {
            {"ą","a"}, {"ć","c"}, {"ę","e"}, {"ł","l"}, {"ń","n"}, {"ó","o"}, {"ś","s"}, {"ż","z"}, {"ź","z"},
            {"Ą","A"}, {"Ć","C"}, {"Ę","E"}, {"Ł","L"}, {"Ń","N"}, {"Ó","O"}, {"Ś","S"}, {"Ż","Z"}, {"Ź","Z"}},

        // sequential replacement
        result = if input_text = null then null 
                 else List.Accumulate(replace_pairs, input_text, (state, pair) => Text.Replace(state, pair{0}, pair{1}))
    in
        result
in
    fx_diacritics