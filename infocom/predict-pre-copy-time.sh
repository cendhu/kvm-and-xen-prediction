source all-results.sh

source defined-dr-$1.sh

rate=("12.5m" "25m" "37.5m" "50m" "62.5m" "75m" "87.5m")
r=("12.5" "25" "37.5" "50" "62.5" "75" "87.5")
ratem=("102" "206" "308" "413" "518" "619" "720")
sindex=0
max_windex=55
rindex=0
max_rindex=7
repeat=1
rm -rf prediction-error-percent-base-$1.txt
rm -rf prediction-error-percent-infocom-$1.txt prediction-error-percent-effective-rate-$1.txt
rm -rf prediction-error-value-base-$1.txt
rm -rf prediction-error-value-infocom-$1.txt prediction-error-value-effective-rate-$1.txt

rm -rf prediction-error-value-base-$1.txt
rm -rf prediction-error-value-infocom-$1.txt prediction-error-value-effective-rate-$1.txt
rm -rf detailed-prediction-error-base-$1.txt
rm -rf detailed-prediction-error-infocom-$1.txt detailed-prediction-error-effective-rate-$1.txt
for ((windex=0; windex < max_windex; windex++))
do
    for ((rindex=0; rindex < max_rindex; rindex++))
    do
        for ((i=0; i < repeat; i++))
        do
            #measured pre-copy time
            tm=`awk 'NR == '$rindex+1'{print $3}' ${rfile[$windex]}`

            ###For (M/R)###

            #predict pre-copy time using base model M/R
            pt=`echo "scale=3; ${sz[$windex]}/${r[$rindex]}" | bc`

            #get prediction error %
            er=`echo "$pt-$tm < 0" | bc`
            if [ $er -eq 1 ]; then
                er=`echo "scale=3; $tm-$pt " | bc`
            else
                er=`echo "scale=3; $pt-$tm " | bc`
            fi
            per=`echo "scale=3; ($er/$tm)*100" | bc`

            #printing the measured pre-copy time, predicted, err and percentage of error
            echo ${workload[$windex]}" "${ratem[$rindex]}" "$tm" "$pt" "$er" "$per >> detailed-prediction-error-base-$1.txt
            echo $per >> prediction-error-percent-base-$1.txt
            echo $er >> prediction-error-value-base-$1.txt



            ###For  (M/R) x (1-(S/R)^{n+1})/(1-(S/R))###
            #retrive number of iteration executed n
            it=`awk 'NR == '$rindex+1'{print $9}' ${rfile[$windex]}`

            #value of S/R is stored in sr
            sr=`echo "scale=3; ${dr[$windex]}/${r[$rindex]}" | bc`

            #predicted pre-copy time
            pt=`echo "scale=3; (${sz[$windex]}/${r[$rindex]}) * ( (1 - ($sr)^$it)/(1- $sr) )" | bc`

            #calculating prediction error
            er=`echo "$pt-$tm < 0" | bc`
            if [ $er -eq 1 ]; then
                er=`echo "scale=3; $tm-$pt " | bc`
            else
                er=`echo "scale=3; $pt-$tm " | bc`
            fi
            per=`echo "scale=3; ($er/$tm)*100" | bc`

            #printing the measured pre-copy time, predicted, err and percentage of error
            echo ${workload[$windex]}" "${ratem[$rindex]}" "$tm" "$pt" "$er" "$per >> detailed-prediction-error-infocom-$1.txt
            echo $per >> prediction-error-percent-infocom-$1.txt
            echo $er >> prediction-error-value-infocom-$1.txt


            ###For  M/(R-S)###
            #get the value of R-S
            sr=`echo "(${ratem[$rindex]}/8)-${dr[$windex]}" | bc`

            #only if R is greater than S, apply this model
            if [ $sr -ge 1 ]; then

                #get R-S
                sr=`echo "scale=3; ${r[$rindex]}-${dr[$windex]}" | bc`

                #predict pre-copy time
                pt=`echo "scale=3; ${sz[$windex]}/$sr" | bc`

                #get prediction error
                er=`echo "$pt-$tm < 0" | bc`
                if [ $er -eq 1 ]; then
                    er=`echo "scale=3; $tm-$pt " | bc`
                else
                    er=`echo "scale=3; $pt-$tm " | bc`
                fi
                per=`echo "scale=3; ($er/$tm)*100" | bc`

                #printing the measured pre-copy time, predicted, err and percentage of error
                echo ${workload[$windex]}" "${ratem[$rindex]}" "$tm" "$pt" "$er" "$per >> detailed-prediction-error-effective-rate-$1.txt
                echo $per >> prediction-error-percent-effective-rate-$1.txt
                echo $er >> prediction-error-value-effective-rate-$1.txt
            fi

        done
    done
done
#<<CC

cat prediction-error-percent-base-$1.txt | sort -n > prediction-error-percent-sorted-base-$1.txt
awk '{c++; print c, $1}' prediction-error-percent-sorted-base-$1.txt > x-$1.txt
mv x-$1.txt prediction-error-percent-sorted-base-$1.txt
rm prediction-error-percent-base-$1.txt
./get_cdf.sh prediction-error-percent-sorted-base-$1.txt > infocom-cdf-error-percent-base-$1.txt


cat prediction-error-percent-infocom-$1.txt | sort -n > prediction-error-percent-sorted-infocom-$1.txt
awk '{c++; print c, $1}' prediction-error-percent-sorted-infocom-$1.txt > x-$1.txt
mv x-$1.txt prediction-error-percent-sorted-infocom-$1.txt
rm prediction-error-percent-infocom-$1.txt
./get_cdf.sh prediction-error-percent-sorted-infocom-$1.txt > infocom-cdf-error-percent-infocom-$1.txt

cat prediction-error-percent-effective-rate-$1.txt | sort -n > prediction-error-percent-sorted-effective-rate-$1.txt
awk '{c++; print c, $1}' prediction-error-percent-sorted-effective-rate-$1.txt > x-$1.txt
mv x-$1.txt prediction-error-percent-sorted-effective-rate-$1.txt
rm prediction-error-percent-effective-rate-$1.txt
./get_cdf.sh prediction-error-percent-sorted-effective-rate-$1.txt > infocom-cdf-error-percent-effective-rate-$1.txt


cat prediction-error-value-base-$1.txt | sort -n > prediction-error-value-sorted-base-$1.txt
awk '{c++; print c, $1}' prediction-error-value-sorted-base-$1.txt > x-$1.txt
mv x-$1.txt prediction-error-value-sorted-base-$1.txt
rm prediction-error-value-base-$1.txt
./get_cdf.sh prediction-error-value-sorted-base-$1.txt > infocom-cdf-error-value-base-$1.txt


cat prediction-error-value-infocom-$1.txt | sort -n > prediction-error-value-sorted-infocom-$1.txt
awk '{c++; print c, $1}' prediction-error-value-sorted-infocom-$1.txt > x-$1.txt
mv x-$1.txt prediction-error-value-sorted-infocom-$1.txt
rm prediction-error-value-infocom-$1.txt
./get_cdf.sh prediction-error-value-sorted-infocom-$1.txt > infocom-cdf-error-value-infocom-$1.txt

cat prediction-error-value-effective-rate-$1.txt | sort -n > prediction-error-value-sorted-effective-rate-$1.txt
awk '{c++; print c, $1}' prediction-error-value-sorted-effective-rate-$1.txt > x-$1.txt
mv x-$1.txt prediction-error-value-sorted-effective-rate-$1.txt
rm prediction-error-value-effective-rate-$1.txt
./get_cdf.sh prediction-error-value-sorted-effective-rate-$1.txt > infocom-cdf-error-value-effective-rate-$1.txt

#CC
