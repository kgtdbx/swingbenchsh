





set echo off heading on underline on;
column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

column end_snap new_value end_snap;
column begin_snap new_value begin_snap;


select d.dbid            dbid
     , d.name            db_name
     , i.instance_number inst_num
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;
select
max(SNAP_ID)-1 begin_snap ,
max(SNAP_ID) end_snap
from dba_hist_snapshot;


Rem      define  inst_num     = 1;
define  num_days     = 1;
Rem      define  inst_name    = 'Instance';
Rem      define  db_name      = 'Database';
Rem      define  dbid         = 4;
Rem      define  begin_snap   = 1794;
Rem      define  end_snap     = 1795;

Rem define  report_type  = 'html';
define  report_type  = 'text';
define  report_name  = awr.txt

@?/rdbms/admin/awrrpti


exit;

