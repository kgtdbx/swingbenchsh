
#. ./conf

DB="$IP:1521:$SID"

echo "DB=$DB"

user_count=5
user_count=1
user_count=${1:-1}

min=200
max=1000
min=2
max=10

runtime=15
runtime=01


#$CHARBENCH -cs $DB  -ld 400 -dt thin -u soe -p soe -uc $user_count -min $min -max $max  -rt 0:$runtime -a  -v users,tpm,tps 
$CHARBENCH -cs $DB  -dt thin -u soe -p soe -uc $user_count -min $min -max $max  -rt 0:$runtime -a  -v users,tpm,tps 

