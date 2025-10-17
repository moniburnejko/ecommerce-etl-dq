// function: fx_number
// purpose: standardize numeric formats, unify decimal separators, and safely convert text numbers to numeric type
// notes: ensures numeric columns (e.g., quantity, price) are correctly parsed for calculations
// author: monika burnejko | 2025

let
    fx_number=(
        number_value as any,
        optional allow_k as nullable logical,            // true: "7.8K"->7800
        optional percent_as_fraction as nullable logical // true: "85%"->0.85
    ) as nullable number =>
    let
        // quick exits
        is_null=number_value=null,
        as_number=if is_null then null else (try Number.From(number_value) otherwise null),
        fast_exit=as_number<>null,

        // normalize text (clean, trim, NBSP -> space, lowercase)
        raw=if fast_exit or is_null then null else Text.From(number_value),
        t0=if raw=null then null else Text.Trim(Text.Clean(raw)),
        nbsp=Character.FromNumber(160),
        t1=if t0=null then null else Text.Replace(t0,Text.From(nbsp)," "),
        t2=if t1=null then null else Text.Replace(Text.Replace(t1,"–","-"),"—","-"),
        t3=if t2=null then null else Text.Replace(t2,"+",""),
        s=if t3=null then null else Text.Lower(t3),

        // defuzz (approx markers)
        fuzzy={"≈","~"},
        s_defuzz=if s=null then null else List.Accumulate(fuzzy,s,(a,b)=>Text.Replace(a,b,"")),
        s_trim=if s_defuzz=null then null else Text.Trim(s_defuzz),

        // remove spaces (thousands)
        s_nospace=if s_trim=null then null else Text.Replace(s_trim," ",""),

        // keep allowed chars only
        allowed=List.Transform({"0".."9"},each _)&{".",",","-","k","%"},
        kept=if s_nospace=null then null else Text.Combine(List.Select(Text.ToList(s_nospace),each List.Contains(allowed,_)),""),

        // K-suffix
        has_k=if kept=null then false else Text.EndsWith(kept,"k"),
        core=if has_k then Text.Start(kept,Text.Length(kept)-1) else kept,

        // unify separators (last separator wins)
        unify=(z as nullable text) as nullable text=>
            if z=null then null else
            let
                has_dot=Text.Contains(z,"."),
                has_comma=Text.Contains(z,","),
                last_dot=if has_dot then Text.PositionOfAny(z,{"."},Occurrence.Last) else -1,
                last_comma=if has_comma then Text.PositionOfAny(z,{","},Occurrence.Last) else -1,
                dec_is_dot=last_dot>last_comma,
                res=if has_dot and has_comma then
                        let thou=if dec_is_dot then "," else ".", no_th=Text.Replace(z,thou,""), std=if dec_is_dot then no_th else Text.Replace(no_th,",",".") in std
                    else if has_comma and not has_dot then Text.Replace(z,",",".")
                    else z
            in res,
        core_std=unify(core),

        // parse
        parsed=if fast_exit or core_std=null then null else (try Number.From(core_std) otherwise null),

        // scale K and %
        allow_k_val=if allow_k=null then false else allow_k,
        allow_pct_val=if percent_as_fraction=null then false else percent_as_fraction,
        scaled_k=if parsed=null then null else if (allow_k_val and has_k) then parsed*1000 else parsed,
        has_pct=if s_trim=null then false else Text.Contains(s_trim,"%"),
        scaled_pct=if scaled_k=null then null else if (allow_pct_val and has_pct) then scaled_k/100 else scaled_k
    in
        if fast_exit then as_number else scaled_pct
in
    fx_number