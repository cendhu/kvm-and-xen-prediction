folder=$1
mig_log_name=new_iter_details.txt
size=("1024" "2048")
rate=("12.5m" "37.5m" "62.5m" "87.5m" "112.5m")
ratem=("100" "300" "500" "700" "900")
sindex=0
max_sindex=1
rindex=0
max_rindex=5
repeat=2
#rm -rf *.txt
for ((sindex=0; sindex < max_sindex; sindex++))
do
    for ((rindex=0; rindex < max_rindex; rindex++))
    do
        for ((i=0; i < repeat; i++))
        do
            dr=`awk -f weighted-dirty-rate.awk $folder/${size[$sindex]}/${rate[$rindex]}/$i/$mig_log_name`
            #echo $dr
            awk -f get-prediction-error.awk -vpdr=$dr -vsdr=$2 $folder/${size[$sindex]}/${rate[$rindex]}/$i/$mig_log_name
        done
    done
done
