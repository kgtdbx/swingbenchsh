col table_name heading "Table" format A28
col num_rows heading "Rows" format 99,999,999,999
col blocks heading "Blocks" format 9,999,999
col index_count heading "Indexes" format 999999
col part_count heading "Partitions" format 99999999
col last_analyzed heading "Analyzed" format A8
col compression heading "Compression" format A12
set linesize 120
prompt
prompt Tables
prompt ======
  SELECT table_name,
	 num_rows,
	 blocks,
	 ts.tablesize,
  CASE
	WHEN t.compression = 'DISABLED' THEN 'Disabled'
	WHEN t.compression = 'ENABLED'  THEN 'Compressed'
  END compression,
  (SELECT COUNT(1) FROM user_indexes i where t.table_name = i.table_name) index_count,
  (SELECT COUNT(1) FROM user_tab_partitions p WHERE t.table_name = p.table_name) part_count,
  CASE
	WHEN (sysdate - last_analyzed) BETWEEN 0 and 0.1 THEN '< Hour'
	WHEN (sysdate - last_analyzed) BETWEEN 0.1 and 1.0 THEN '< Day'
	WHEN (sysdate - last_analyzed) BETWEEN 1.0 and 7.0 THEN '< Week'
	WHEN (sysdate - last_analyzed) BETWEEN 7.0 and 28.0 THEN '< Month'
	ELSE '> Month'
  END last_analyzed
  FROM user_tables t,
        (SELECT segment_name,
	  CASE
	       WHEN SUM(s.bytes) BETWEEN 0 and 1024 THEN LPAD(SUM(s.bytes) || 'b',8)
	       WHEN SUM(s.bytes) BETWEEN 1024 and 1048576 THEN LPAD(ROUND((SUM(s.bytes)/1024)) || 'k',8)
	       WHEN SUM(s.bytes) BETWEEN 1048576 and 1073741824 THEN LPAD(ROUND((SUM(s.bytes)/1073741824),2) || 'M',8)
	       else LPAD(ROUND((SUM(s.bytes)/1073741824),2) || 'G',8)
	  END tablesize
	 FROM user_segments s
	 WHERE s.segment_type in ('TABLE', 'TABLE PARTITION', 'TABLE_SUBPARTITION')
	 GROUP BY s.segment_name ) ts
  WHERE t.table_name = ts.segment_name;
