// function: fx_date
// purpose: parse and convert various date formats into standard iso format
// notes: supports multiple regional date styles and ensures consistent date typing
// author: monika burnejko | 2025

let
    fx_date=(
        x as any,
        optional preferred_cultures as nullable list // e.g. {"en-GB","en-US","pl-PL"}
    ) as nullable date =>
    let
        // fast path for typed values
        fast_date=if Value.Is(x,type date) then x else null,
        fast_dt=if fast_date<>null then fast_date
                else if Value.Is(x,type datetime) then Date.From(x)
                else if Value.Is(x,type datetimezone) then Date.From(DateTimeZone.RemoveZone(x))
                else null,

        // early exit
        early=fast_dt,

        // text prep
        txt_raw=if early<>null or x=null then null else Text.From(x),
        t0=if txt_raw=null then null else Text.Trim(Text.Clean(txt_raw)),
        nbsp=Character.FromNumber(160),
        t1=if t0=null then null else Text.Replace(t0,Text.From(nbsp)," "),
        t2=if t1=null then null else Text.Replace(Text.Replace(t1,".","-"),"/","-"),

        // excel serial (numeric or numeric text)
        serial_num=if early<>null or t2=null then null else (try Number.From(t2) otherwise null),
        is_serial=serial_num<>null and serial_num>=1 and serial_num<600000,
        from_serial=if is_serial then Date.AddDays(#date(1899,12,30),Number.RoundDown(serial_num)) else null,

        // ISO-like or datetime/datetimezone
        try_iso=if early<>null or t2=null or from_serial<>null then null else (try Date.FromText(t2) otherwise null),
        try_dt=if early<>null or t2=null or from_serial<>null or try_iso<>null then null else (try DateTime.FromText(t2) otherwise null),
        try_dtz=if early<>null or t2=null or from_serial<>null or try_iso<>null or try_dt<>null then null else (try DateTimeZone.FromText(t2) otherwise null),
        from_dt=if try_iso<>null then try_iso else if try_dt<>null then Date.From(try_dt) else if try_dtz<>null then Date.From(try_dtz) else null,

        // cultural parsing (priority order)
        cultures=if preferred_cultures=null then {"en-GB","en-US","pl-PL"} else preferred_cultures,
        try_by_culture=(s as text,cs as list) as nullable date =>
            List.Accumulate(cs,null,(acc,c)=>if acc<>null then acc else (try Date.FromText(s,c) otherwise null)),
        from_culture=if early<>null or t2=null or from_serial<>null or from_dt<>null then null else try_by_culture(t2,cultures),

        // final
        result=if early<>null then early else if from_serial<>null then from_serial else if from_dt<>null then from_dt else from_culture
    in
        result
in
    fx_date