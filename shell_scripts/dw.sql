
set echo on
set define off

alter table soe.order_items parallel 4;
   alter table soe.orders parallel 4;
   alter table soe.customers parallel 16;
   alter table soe.logon parallel 4;
   alter index     CUST_UPPER_NAME_IX parallel 4;
   alter index     CUSTOMERS_PK parallel 4;
   alter index     ITEM_ORDER_IX parallel 16;
   alter index     ORDER_PK parallel 16;
   alter index     INV_PRODUCT_IX parallel 4;
   alter index     ORD_CUSTOMER_IX parallel 4;
   alter index     ORDER_ITEMS_PK parallel 4;

!sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awrsnap.sql

set timing on
spool ibm_dw
select /*+  full(customers) */ count(account_mgr_id) from customers;
!sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awrsnap.sql   > /dev/null 2>&1
!sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awr.sql   > /dev/null 2>&1
!mv awr.txt dss_customer_full1.awr
select /*+  full(customers) */ count(account_mgr_id) from customers;
!sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awrsnap.sql   > /dev/null 2>&1
!sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awr.sql   > /dev/null 2>&1
!mv awr.txt dss_customer_full2.awr
select /*+  full(orders) */ count(warehouse_id) from orders;
!sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awrsnap.sql   > /dev/null 2>&1
!sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awr.sql   > /dev/null 2>&1
!mv awr.txt dss_orders_full1.awr
select /*+  full(orders) */ count(warehouse_id) from orders;
!sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awrsnap.sql   > /dev/null 2>&1
!sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awr.sql   > /dev/null 2>&1
!mv awr.txt dss_orders_full2.awr
select /*+  full(order_items) */ count(quantity) from order_items;
!sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awrsnap.sql   > /dev/null 2>&1
!sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awr.sql   > /dev/null 2>&1
!mv awr.txt dss_orders_items_full1.awr
select /*+  full(order_items) */ count(quantity) from order_items;
!sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awrsnap.sql   > /dev/null 2>&1
!sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awr.sql   > /dev/null 2>&1
!mv awr.txt dss_orders_items_full2.awr
select /*+  full(logon) */ count(logon_date) from logon;
select /*+  full(logon) */ count(logon_date) from logon;
select /*+ full(INVENTORIES) */ count(*) from INVENTORIES;
select /*+ full(INVENTORIES) */ count(*) from INVENTORIES;
select /*+ index_ffs(INVENTORY_PK) */ count(*) from INVENTORIES;
select /*+ index_ffs(INVENTORY_PK) */ count(*) from INVENTORIES;
select /*+ index_ffs(CUSTOMERS CUSTOMERS_PK) */ count(CUSTOMER_ID) from CUSTOMERS;
select /*+ index_ffs(CUSTOMERS CUSTOMERS_PK) */ count(CUSTOMER_ID) from CUSTOMERS;
select /*+ index_ffs(CUSTOMERS CUST_UPPER_NAME_IX) */  count(SYS_NC00009$) from CUSTOMERS;
select /*+ index_ffs(CUSTOMERS CUST_UPPER_NAME_IX) */  count(SYS_NC00009$) from CUSTOMERS;
select /*+ index_ffs(ORDER_ITEMS ITEM_ORDER_IX) */  count(ORDER_ID) from ORDER_ITEMS;
select /*+ index_ffs(ORDER_ITEMS ITEM_ORDER_IX) */  count(ORDER_ID) from ORDER_ITEMS;
select /*+ index_ffs(ORDERS ORDER_PK) */  count(ORDER_ID) from ORDERS;
select /*+ index_ffs(ORDERS ORDER_PK) */  count(ORDER_ID) from ORDERS;
select /*+ index_ffs(INVENTORIES INV_PRODUCT_IX) */ count(PRODUCT_ID) from INVENTORIES;
select /*+ index_ffs(INVENTORIES INV_PRODUCT_IX) */ count(PRODUCT_ID) from INVENTORIES;
select /*+ index_ffs(ORDERS ORD_CUSTOMER_IX) */ count(CUSTOMER_ID) from ORDERS;
select /*+ index_ffs(ORDERS ORD_CUSTOMER_IX) */ count(CUSTOMER_ID) from ORDERS;
select /*+ index_ffs(ORDER_ITEMS ORDER_ITEMS_PK) */ count(ORDER_ID) from ORDER_ITEMS;
select /*+ index_ffs(ORDER_ITEMS ORDER_ITEMS_PK) */ count(ORDER_ID) from ORDER_ITEMS;
spool off
set timing off

   alter table soe.order_items parallel 1;
   alter table soe.customers parallel 1;
   alter table soe.orders parallel 1;
   alter table soe.logon parallel 1;
   alter index     CUST_UPPER_NAME_IX parallel 1;
   alter index     ITEM_ORDER_IX parallel 1;
   alter index     ORDER_PK parallel 1;
   alter index     CUSTOMERS_PK parallel 1;
   alter index     INV_PRODUCT_IX parallel 1;
   alter index     ORD_CUSTOMER_IX parallel 1;
   alter index     ORDER_ITEMS_PK parallel 1;

exit
