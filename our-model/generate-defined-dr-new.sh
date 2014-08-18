a=(
'Um'
'Un1'
'Un2'
'Un3'
'Un4'
'Un5'
'Un6'
'Un7'
'Un8'
'Un9'
'Un10'
)

for ((i=0; i<11; i++))
do
    printf ${a[$i]}"=(\n"
    awk '{print "\""$('$i'+2)"\""} ' $1
    printf ")\n"
done
echo "mwws=("
awk '{print "\""$2"\""} ' $2
echo ")"
