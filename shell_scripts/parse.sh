for i in `ls -1rt $1/*out`; do
grep "[0-9] .M" $i | \
awk '{ sum+=$4; ct++ } END { printf("%10s %10d\n",file, sum/ct) }' file=$i
done


