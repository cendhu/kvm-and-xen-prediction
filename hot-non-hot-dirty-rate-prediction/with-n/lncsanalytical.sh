time=(
'10'
'50'
)

prob=(
'.5'
'.6'
'.7'
'.8'
'.9'
)


for ((i=0; i<2; i++))
do
    for ((j=0; j<5; j++))
    do
        #echo "dr=(" > defined-dr-lncsanalytical-${time[$i]}-${prob[$j]}.sh
        #awk '{print "\"("$2*$3+(1-$2)*$4"/256)\""}' lncsanalytical-${time[$i]}-${prob[$j]}.txt >> defined-dr-lncsanalytical-${time[$i]}-${prob[$j]}.sh
        #echo ")" >> defined-dr-lncsanalytical-${time[$i]}-${prob[$j]}.sh
        ./predict-pre-copy-time.sh lncsanalytical-${time[$i]}-${prob[$j]}
    done
done

