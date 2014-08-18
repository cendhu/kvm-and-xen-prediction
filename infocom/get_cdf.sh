count=`wc -l $1 | awk '{print $1}'`
#pages=`awk '{s+=$2} END{print s}' $1`
awk -vc=$count -vfl=$1 '{
    system("awk -vno="$2" -vc="c" -f cdf.awk "fl);
}' $1
