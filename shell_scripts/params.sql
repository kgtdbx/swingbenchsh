set pagesize 1000
col name for  a35
col value for a35
select name,value from v$parameter where ISDEFAULT='FALSE';
select count(*) from v$dnfs_servers;
select count(*) from v$dnfs_files;
select count(*) from v$dnfs_channels;
show sga

exit
