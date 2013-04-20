#!/bin/bash


# assumes and users /home/oradata
# users ORACLE_HOME to create init.ora in $ORACLE_HOME/dbs


echo "give ORACLE_SID:"
read ORACLE_SID

export ORACLE_SID=$ORACLE_SID

mkdir -p /home/oradata/${ORACLE_SID}

for i in 1; do
cat << EOF
# needs to be changed:
db_create_file_dest = '/home/oradata/${ORACLE_SID}/'
control_files=('/home/oradata/${ORACLE_SID}/cntl${ORACLE_SID}.dbf')
db_name = ${ORACLE_SID}

# can stay the same:
compatible = 11.2.0.2
UNDO_MANAGEMENT=AUTO
db_block_size = 8192
db_files = 300
processes = 100
memory_max_target = 2G
sga_target=1G
#shared_pool_size = 500M
filesystemio_options=setall
EOF
done > $ORACLE_HOME/dbs/init${ORACLE_SID}.ora

for i in 1; do
cat << EOF
spool create${ORACLE_SID}.lis
startup force exclusive nomount 

create database ${ORACLE_SID} CONTROLFILE REUSE
SET DEFAULT BIGFILE TABLESPACE
maxinstances 1
maxdatafiles 1024
maxlogfiles 16
noarchivelog
datafile size 50M
logfile SIZE 4G, SIZE 4G, SIZE 4G 
/

alter tablespace SYSTEM autoextend on;
alter tablespace SYSAUX autoextend on;
set echo off

@?/rdbms/admin/catalog
@?/rdbms/admin/catproc

connect / as sysdba 

@?/sqlplus/admin/pupbld

create BIGFILE temporary 
tablespace TEMP tempfile '/home/oradata/${ORACLE_SID}/temp_01.dbf' size 200M ;
alter tablespace TEMP autoextend on next 200m maxsize unlimited;

--create BIGFILE tablespace SOE datafile '/home/oradata/SOE1G/soe_01.dbf' size 1G 
--NOLOGGING ONLINE PERMANENT EXTENT MANAGEMENT LOCAL AUTOALLOCATE SEGMENT SPACE MANAGEMENT AUTO ;
--alter tablespace SOE autoextend on next 200m maxsize unlimited;

--create BIGFILE tablespace IOPS datafile '/home/oradata/SLOB/iops_01.dbf' size 1G 
--NOLOGGING ONLINE PERMANENT EXTENT MANAGEMENT LOCAL AUTOALLOCATE SEGMENT SPACE MANAGEMENT AUTO ;
--alter tablespace IOPS autoextend on next 200m maxsize unlimited;

EOF
done > create${ORACLE_SID}.sql


