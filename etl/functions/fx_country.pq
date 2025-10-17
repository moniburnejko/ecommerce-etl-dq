// function: fx_country
// purpose: standardize country names using predefined mapping (e.g., "de", "deutschland" → "Germany")
// notes: improves consistency for geographic dimensions and joins across tables
// author: monika burnejko | 2025

let
    fx_country = (x as nullable text) as nullable text =>
    let
        // handle nulls and normalize case
        input_text = if x = null then null else Text.Lower(Text.Trim(x)),

        // mapping of country variations to standardized names
        country_map = [
            poland = "Poland", polska = "Poland", republic of poland = "Poland", pl = "Poland",
            germany = "Germany", deutschland = "Germany", de = "Germany",
            france = "France", fr = "France",
            czechia = "Czechia", czech republic = "Czechia", cz = "Czechia",
            lithuania = "Lithuania", lt = "Lithuania"],

        // match against map or return properly capitalized input
        standardized = 
            if input_text = null then null 
            else Record.FieldOrDefault(country_map, input_text, Text.Proper(x))
    in
        standardized
in
    fx_country