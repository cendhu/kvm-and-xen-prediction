workload=(
"file-server/10m"  #1
"file-server/20m"  #2
"kernel/1"         #3
"kernel/2"         #4
"mediawiki-ws/20C" #5
"mediawiki-db/20C" #6
"mediawiki-ws/10C" #7
"mediawiki-db/10C" #8
"rubis-ws/300C"    #9
"rubis-db/300C"    #10
"rubis-ws/100C"    #11
"rubis-db/100C"    #12
"rubis-ws/50C"     #13
"rubis-db/50C"     #14
)

ittime=(
"file-server-10m.txt"
"file-server-20m.txt"
"kernel-1.txt"
"kernel-2.txt"
"mediawiki-ws-20C.txt"
"mediawiki-db-20C.txt"
"mediawiki-ws-10C.txt"
"mediawiki-db-10C.txt"
"rubis-ws-300C.txt"
"rubis-db-300C.txt"
"rubis-ws-100C.txt"
"rubis-db-100C.txt"
"rubis-ws-50C.txt"
"rubis-db-50C.txt"
)

dr=(
"(3388/256.0)"
"(6348/256.0)"
"(12451/256.0)"
"(18889/256.0)"
"(117859/256.0)"
"(3337/256.0)"
"(74674/256.0)"
"(2999/256.0)"
"(40786/256.0)"
"(20598/256.0)"
"(18609/256.0)"
"(13071/256.0)"
"(10601/256.0)"
"(13043/256.0)"
)

mig_log_name=migration_log_without_skip.txt
rate=("12.5m" "37.5m" "62.5m" "87.5m" "112.5m")
r=("12.5" "37.5" "62.5" "87.5" "112.5")
ratem=("100" "300" "500" "700" "900")
sindex=0
max_windex=14
rindex=0
max_rindex=5
repeat=1
path="/root/cloning/without-skip/result-XEN-SAC/"
rm -rf detailed-prediction-error-td.txt detailed-prediction-error-effective-rate.txt
for ((windex=0; windex < max_windex; windex++))
do
    for ((rindex=0; rindex < max_rindex; rindex++))
    do
        for ((i=0; i < repeat; i++))
        do

            ###For  (M/R) x (1-(S/R)^{n+1})/(1-(S/R))###
            #retrive number of iteration executed n
            it=`awk 'NR == '$rindex+1'{print $9}' $path/${ittime[$windex]}`

            #measured pre-copy time
            tm=`awk 'NR == '$rindex+1'{print $3}' $path/${ittime[$windex]}`

            #value of S/R is stored in sr
            sr=`echo "scale=3; ${dr[$windex]}/${r[$rindex]}" | bc`

            #predicted pre-copy time
            pt=`echo "scale=3; (1024/${r[$rindex]}) * ( (1 - ($sr)^$it)/(1- $sr) )" | bc`

            #calculating prediction error
            er=`echo "$pt-$tm < 0" | bc`
            if [ $er -eq 1 ]; then
                er=`echo "scale=3; $tm-$pt " | bc`
            else
                er=`echo "scale=3; $pt-$tm " | bc`
            fi
            per=`echo "scale=3; ($er/$tm)*100" | bc`

            #printing the measured pre-copy time, predicted, err and percentage of error
            echo ${workload[$windex]}" "${ratem[$rindex]}" "$tm" "$pt" "$er" "$per >> detailed-prediction-error-infocom.txt
            echo $per >> prediction-error-infocom.txt


            ###For  M/(R-S)###
            #get the value of R-S
            sr=`echo "(${ratem[$rindex]}/8)-${dr[$windex]}" | bc`

            #only if R is greater than S, apply this model
            if [ $sr -ge 1 ]; then

                #get R-S
                sr=`echo "scale=3; ${r[$rindex]}-${dr[$windex]}" | bc`

                #predict pre-copy time
                pt=`echo "scale=3; 1024/$sr" | bc`

                #get prediction error
                er=`echo "$pt-$tm < 0" | bc`
                if [ $er -eq 1 ]; then
                    er=`echo "scale=3; $tm-$pt " | bc`
                else
                    er=`echo "scale=3; $pt-$tm " | bc`
                fi
                per=`echo "scale=3; ($er/$tm)*100" | bc`

                #printing the measured pre-copy time, predicted, err and percentage of error
                echo ${workload[$windex]}" "${ratem[$rindex]}" "$tm" "$pt" "$er" "$per >> detailed-prediction-error-effective-rate.txt
                echo $per >> prediction-error-effective-rate.txt
            fi
        done
    done
done

cat prediction-error-infocom.txt | sort -n > prediction-error-sorted-infocom.txt
awk '{c++; print c, $1}' prediction-error-sorted-infocom.txt > x.txt
mv x.txt prediction-error-sorted-infocom.txt
rm prediction-error-infocom.txt
./get_cdf.sh prediction-error-sorted-infocom.txt > weight-cdf-error-infocom.txt

cat prediction-error-effective-rate.txt | sort -n > prediction-error-sorted-effective-rate.txt
awk '{c++; print c, $1}' prediction-error-sorted-effective-rate.txt > x.txt
mv x.txt prediction-error-sorted-effective-rate.txt
rm prediction-error-effective-rate.txt
./get_cdf.sh prediction-error-sorted-effective-rate.txt > weight-cdf-error-effective-rate.txt
#cat prediction-error.txt | sort -n > prediction-error-sorted.txt
#./get_cdf.sh prediction-error-sorted.txt > cdf-error.txt
