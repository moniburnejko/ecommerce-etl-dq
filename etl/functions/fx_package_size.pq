// function: fx_package_size
// purpose: parse and normalize product packaging text (e.g., "12x0.5L", "500g") into structured record fields
// notes: outputs three columns - pack_count, quantity, and unit — standardized to L or kg
// author: monika burnejko | 2025

let
    fx_package_size = (x as any) as nullable record =>
    let
        // handle nulls and normalize input
        raw = if x = null then null else Text.Trim(Text.From(x)),
        null_record = [pack_count = null, quantity = null, unit = null],
        safe = if raw = null or raw = "" then null else raw,

        // short-circuit on null
        result =
            if safe = null then null_record else
            let
                // normalize: unify separators, lowercase, remove inner spaces
                norm1 = Text.Replace(safe, "×", "x"),
                norm2 = Text.Lower(Text.Replace(norm1, ",", ".")),
                compact = Text.Replace(
                              Text.Trim(
                                  Text.Combine(List.Select(Text.Split(norm2, " "), each _ <> ""), " ")), " ", ""),

                // helpers to extract numeric and alphabetic parts
                to_num = (t as text) => Text.Select(t, {"0".."9","."}),
                to_unit = (t as text) => Text.Select(t, {"A".."Z","a".."z"}),

                // split by 'x' (pack multiplier)
                parts = Text.Split(compact, "x"),
                n = List.Count(parts),

                left = if n >= 1 then parts{0} else "",
                right = if n >= 2 then parts{1} else "",

                left_num = to_num(left),
                left_unit = to_unit(left),
                right_num = to_num(right),
                right_unit = to_unit(right),

                has_x = n > 1,

                // choose pack_count and the token containing value+unit
                pack_count_text =
                    if not has_x then "1"
                    else if left_unit = "" and left_num <> "" then left_num
                    else if right_unit = "" and right_num <> "" then right_num
                    else if left_num <> "" then left_num
                    else if right_num <> "" then right_num
                    else "1",

                unit_source =
                    if not has_x then left
                    else if left_unit <> "" then left
                    else right,

                raw_value_text = to_num(unit_source),
                raw_unit_text = to_unit(unit_source),
                unit_symbol = Text.Lower(raw_unit_text),

                pack_count_try = try Number.From(pack_count_text) otherwise null,
                pack_count = if pack_count_try = null then 1 else Number.RoundDown(pack_count_try),

                value_num_try = if raw_value_text <> "" then try Number.From(raw_value_text) otherwise null else null,
                value_num = if value_num_try = null then null else value_num_try,

                // unit conversions to liters and kilograms
                unit_map = [
                    ml = [factor = 0.001, target = "L"],
                    l = [factor = 1.0, target = "L"],
                    g = [factor = 0.001, target = "kg"],
                    kg = [factor = 1.0, target = "kg"]],
                has_conv = Record.HasFields(unit_map, unit_symbol),
                conv_rec = if has_conv then Record.Field(unit_map, unit_symbol) else null,

                final_value =
                    if value_num = null then null
                    else if conv_rec <> null then Number.Round(value_num * conv_rec[factor], 2)
                    else value_num,

                final_unit =
                    if conv_rec <> null then conv_rec[target]
                    else if unit_symbol <> "" then unit_symbol
                    else null
            in
                [pack_count = pack_count, quantity = final_value, unit = final_unit]
    in
        result
in
    fx_package_size