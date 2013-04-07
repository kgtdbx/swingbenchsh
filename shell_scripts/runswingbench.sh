#!/bin/bash

DB="$IP:1521:$SID"

min=2
max=10

min=${THINKMIN:-100}
max=${THINKMAX:-200}
runtime=${RUNTIME:-01}
let seconds=$runtime*60+5
SQL_PATH=${SQL_PATH:-'./'}
USER_COUNTS=${USER_COUNTS:-"1 5 10 20 30 60 100 200"}

LOOPS=${LOOPs:-1}
DSS=${DSS:-0}
DSS1=${DSS1:-0}
COLD=${COLD:-0}
WARM=${WARM:-0}
EVAL=${EVAL:-0}

echo " LOOPS=$LOOPS"
echo " DSS=$DSS"
echo " COLD=$COLD"
echo " WARM=$WARM"
echo " EVAL=$EVAL"
echo " THINKMIN=$THINKMIN"
echo " THINKMAX=$THINKMAX"
echo " RUNTIME=$RUNTIME"
echo " USER_COUNTS=$USER_COUNTS"
echo  "DB=$DB"

echo "ok?"
read ok

function runcmd {
    echo $cmd
    if   [ $EVAL  -eq 1 ] ; then
       eval  $cmd
    fi
    sleep .1
}

cmd="sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/params.sql > ${SID}_params.out"
runcmd $cmd

run()
{
       echo "user_count=$user_count"

       filename="${SID}_${type}_run${count}_uc${user_count}_oramon.lst "
       echo "oramon.sh system sys $IP $SID 1521  >  $filename &"
       if   [ $EVAL  -eq 1 ] ; then
          oramon.sh system sys $IP $SID 1521  > $filename &
          ORAMON=$!
       fi

       cmd="sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awrsnap.sql"
       runcmd $cmd

       # don't seem to be catching the PID correctly so instead of eval, just executioning the command
       # eval " ( $cmd ) & "
       args="-cs $DB  -dt thin -u soe -p soe -uc $user_count -min $min -max $max  -rt 0:$runtime -a  -v users,tpm,tps"
       output="${SID}_${type}_run${count}_uc${user_count}.out" 
       cmd="$CHARBENCH $args"
       echo $cmd
       if   [ $EVAL  -eq 1 ] ; then
          $CHARBENCH $args > $output &
          CHARBID=$!
       fi

       # I sleep instead of wait because there have been a few times where
       # charbench keeps running, thus make sure it's killed after alotted time
       if   [ $EVAL  -eq 1 ] ; then
          sleep 2
          tail -f $output &
          TAIL=$!
       fi
       cmd="sleep $seconds"
       runcmd $cmd
       cmd="kill -9 $CHARBID #charbe"
       runcmd $cmd
       cmd="kill -9 $TAIL #tail"
       runcmd $cmd

       cmd="rm /tmp/MONITOR$SID/clean/*end"
       runcmd $cmd

       cmd="sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awrsnap.sql"
       runcmd $cmd
       cmd="sqlplus.sh system sys $IP $SID 1521 $SQL_PATH/awr.sql"
       runcmd $cmd
       filename="${SID}_${type}_run${count}_uc${user_count}.awr" 
       cmd="mv awr.txt $filename" 
       runcmd $cmd
       cmd="sleep 5"
       runcmd $cmd
       #cmd="ps -ef | grep charbe | grep -v grep | awk '{print \$2}'  | xargs kill -9"
       procs=$(ps -ef | grep charbe | grep -v grep | awk '{print $2}'  )
       cmd="kill -9 $procs # grep charbe"
       runcmd $cmd
       cmd="kill -9 $ORAMON #oramon"
       runcmd $cmd
}

count=1
loops=0

# COLD cache LOAD

   if [ $COLD -eq 1 ] ; then
      type="cold"
      loops=$(expr $loops + $LOOPS)
      echo ""
      echo "starting cold runs"
      while [ $count -le $loops ]; do
        for user_count in $USER_COUNTS; do
          echo ""
           run
        done
        count=`expr $count + 1`
      done
      if   [ $EVAL  -eq 1 ] ; then
        sqlplus / as sysdba << EOF
          startup force
EOF
      fi
   fi

#  DSS load ( warming of cache )
#  dw.sql runs it's own AWR collection

   if [ $DSS -eq 1 ] ; then
      echo ""
      echo "starting DSS runs"
      cmd="sqlplus.sh soe soe $IP $SID 1521 $SQL_PATH/dw.sql"
      runcmd $cmd
      echo ""
   fi
   # DSS1 just runs the queries once instead of twice
   if [ $DSS1 -eq 1 ] ; then
      echo ""
      echo "starting DSS1 runs"
      cmd="sqlplus.sh soe soe $IP $SID 1521 $SQL_PATH/dw1.sql"
      runcmd $cmd
      echo ""
   fi


# WARM cache  LOAD

   if [ $WARM -eq 1 ] ; then
      type="warm"
      loops=$(expr $loops + $LOOPS)
      echo "starting warm runs"
      while [ $count -le $loops ]; do
        for user_count in  $USER_COUNTS; do
          echo ""
           run
          echo ""
        done
        count=`expr $count + 1`
      done
   fi


dt=`date +'%Y_%m_%d_%H:%M:%S'`
dt=`date +'%Y_%m_%d_%H%M'`
dir="run$dt"
cmd="mkdir $dir"
runcmd $cmd
filename="${SID}_${type}_dss.lst "
cmd="mv ibm_dw.lst $filename"
runcmd $cmd
cmd="mv *out *awr *lst  $dir"
runcmd $cmd
cmd="parse.sh $dir   >   $dir/results"
runcmd $cmd
cmd="parsesql.sh $dir/$filename.lst   >> $dir/results"
runcmd $cmd
cmd="cat $dir/results"
runcmd $cmd

