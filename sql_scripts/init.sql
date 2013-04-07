
col parameter for a35
col instance_value for a20
select
        a.ksppinm  parameter,
        c.ksppstvl instance_value
  from
        x$ksppi a,
        x$ksppsv c
 where
        a.indx = c.indx
    and lower(ksppinm) like '%&name%'
/

