
col index_name for a24
col table_name for a20
col column_name for a20
set pagesize 0
set linesie 150
spool indrs.lst
select
'select /*+ index_ffs('||table_name||' '||index_name||') */ count('||
column_name||') from '||table_name||';'
from user_ind_columns
where column_position=1
order by index_name, table_name, column_position
/
spool off

