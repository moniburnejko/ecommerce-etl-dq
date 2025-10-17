// function: fx_text
// purpose: clean text values by removing control characters, collapsing whitespace, normalizing punctuation, and applying optional casing mode
// notes: used for standardizing text columns (eg., product_name, category, supplier)
// author: monika burnejko | 2025

let
    fx_text=(txt as nullable text, optional casing as nullable text) as nullable text =>
    let
        // quick exit
        is_empty=txt=null or Text.Trim(Text.From(txt))="",
        result=if is_empty then null else
            let
                // normalize controls + nbsp
                t0=Text.Clean(Text.From(txt)),
                nbsp=Character.FromNumber(160),
                t1=Text.Replace(t0,Text.From(nbsp)," "),

                // collapse any whitespace to single space
                delims=" #(tab)#(cr)#(lf)"&Text.From(nbsp),
                tokens=List.Select(Text.SplitAny(t1,delims),each _<>""),
                t2=Text.Combine(tokens," "),

                // standardize punctuation
                repl={{"–","-"},{"—","-"},{"’","'"},{"‘","'"}},
                t3=List.Accumulate(repl,t2,(acc,p)=>Text.Replace(acc,p{0},p{1})),
                t4=Text.Trim(t3),

                // casing
                mode=if casing=null then "proper" else Text.Lower(Text.From(casing)),
                out= if mode="lower" then Text.Lower(t4)
                     else if mode="upper" then Text.Upper(t4)
                     else if mode="none" then t4
                     else Text.Proper(t4)
            in out
    in
        result
in
    fx_text