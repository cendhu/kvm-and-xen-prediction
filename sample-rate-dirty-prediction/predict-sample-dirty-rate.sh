workload=(
"file-server"
"kernel"
"mediawiki-ws/20C"
"mediawiki-ws/10C"
"mediawiki-db"
"rubis-ws/300C"
"rubis-db/300C"
"rubis-ws/100C"
"rubis-db/100C"
)

dr=(
"6073.2"
"22074"
"119251"
"75098.9"
"3134.7"
"39648.6"
"20474.6"
"18436.6"
"13374.6"
)

mig_log_name=migration_log_without_skip.txt
rate=("12.5m" "37.5m" "62.5m" "87.5m" "112.5m")
ratem=("100" "300" "500" "700" "900")
sindex=0
max_windex=9
rindex=0
max_rindex=5
repeat=2
rm -rf prediction-error-sorted.txt prediction-error.txt
for ((windex=0; windex < max_windex; windex++))
do
    for ((rindex=0; rindex < max_rindex; rindex++))
    do
        for ((i=0; i < repeat; i++))
        do
            awk -f get-prediction-error.awk -vsdr=${dr[$windex]} /root/cloning/without-skip/${workload[$windex]}/1024/${rate[$rindex]}/$i/$mig_log_name >> prediction-error.txt
        done
    done
done

cat prediction-error.txt | sort -n > prediction-error-sorted.txt
./get_cdf.sh prediction-error-sorted.txt > cdf-error.txt
