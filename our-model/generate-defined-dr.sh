a=(
'Um'
'Un'
'Sm'
'Sn12'
'Sn'
)

for ((i=0; i<5; i++))
do
    printf ${a[$i]}"=(\n"
    awk '{print "\""$('$i'+2)"\""} ' $1
    printf ")\n"
done
echo "mwws=("
awk '{print "\""$2"\""} ' $2
echo ")"
