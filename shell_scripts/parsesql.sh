
grep Ela $1 | sed -e 's/Elapsed: //' | awk -F: '
BEGIN{ ct=0}
{ printf("%8.2f : ",$1*3600+$2*60+$3)
  ct++
}
{ if ( ct%2 == 0 ) printf("\n") }' > out1.tmp

grep SQL $1  | grep -v awr | awk -F: '
BEGIN{ ct=0}
{ ct++ }
{ if ( ct%2 == 0 ) print $0 }' | sed -e 's/.*select//' | grep -v awr > out2.tmp

paste out1.tmp out2.tmp > out3.tmp
cat out3.tmp | awk -F: '{ printf("%5.2f ; %s\n", $1/$2, $0 ) }' | grep -v alter | sed -e 's/:/;/g'

