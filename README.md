
source ENV

   $ . ENV

To test virtual, make sure the physical is shutdown 

  export ORACLE_SID=physSID
  sqlplus / as sysdba << EOF
  shutdown immediate
EOF

Go into Delphix UI and provision a VDB called "V1"
If the  VDB already exists, drop "V1" and then recreate it as "V1". 
Then on VDB host
         
     export ORACLE_SID=V1
     cd $ORACLE_HOME/dbs
     sqlplus / as sysdba
          grant connect to system identified by sys;
          create spfile from pfile;
          create pfile from spfile;
          !rm spfile$ORACLE_SID.ora
          !vi init$ORACLE_SID.ora 

        add/modify (delete process, sga_target memory_max lines, then just add these )
           *.sga_target=0
           *.sga_max_size=700M
           *.db_cache_size   = 100M
           *.db_file_multiblock_read_count=16
           *.filesystemio_options=setall
           *.processes=200
           *.log_buffer=33554432

         !cp init$ORACLE_SID.ora init$ORACLE_SID.ora.new
         shutdown immediate;
         startup mount;
         alter database noarchivelog;
         alter database open;

Do the same procedure and make a V2 VDB on a different database host
The VM for V1 and the VM for V2 should be two different VMs
on the same ESX host at the Delphix VM

Once the VDB is up and running with the new init.ora go to

on machine  with V1 do

   cd  /home/oracle/benchmark
   mkdir V1 
   cp phys/conf V1
   cd V1
   vi  conf
   # make sure conf has the correct SID a
   ./run1.sh 1  # test connection is working, hit ^C after successful TPM values ie > 0

Do the above stesp on machine with V2 as well
  

   TESTS TO RUN

       1. Run V1 tests with 
 
         $ cd benchmark/V1  
         $ runall.sh
   
       2. Follow that sequentially by a V2 tests with

         $ cd benchmark/V2  # dir with conf file, make sure SID is V2 in conf
         $ rundss.sh
   
       3. Follow that with concurrently running V1 and V2 tests with
   
         $ cd benchmark/V1  
         $ runoltp.sh

         $ cd benchmark/V2  
         $ runoltp.sh
   NOTE: in test 3, runoltp.sh has to be run on different machines. 
   There should be a VM with virtual database V1 and another VM with V2
   Each machine should have swingbench installed and runoltp should be
   run on the VM with that VDB


NOTE:

     After any reboot VDB  host requires 
     in  /etc/sysctl.conf modify

          sunrpc.tcp_slot_table_entries = 128
     then  

          sysctl -p

     Verify with

          sysctl -A | grep sunrpc

     requires all NFS mounts to be remounted to take effect

     After any reboot VDB host also requires

          mv /dev/random /dev/random.orig
          ln -s /dev/urandom /dev/random

     (see https://kr.forums.oracle.com/forums/thread.jspa?threadID=941911  )

