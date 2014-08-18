source all-results.sh
source all-workload.sh
source df.sh
source alpha.sh

rate=("12.5m" "25m" "37.5m" "50m" "62.5m" "75m" "87.5m")
r=("12.5" "25" "37.5" "50" "62.5" "75" "87.5")
ratem=("102" "206" "308" "413" "518" "619" "720")
sindex=0
max_windex=55
rindex=0
max_rindex=7
repeat=3

rm -rf base-$1.txt
rm -rf hpdc-$1.txt
rm -rf infocom-$1.txt
rm -rf effective-rate-$1.txt

rm execute-command.sh
mig_log_name=migration_log_without_skip.txt
rm hpdc-dirty-rate.txt
for ((windex=0; windex < max_windex; windex++))
do
    for ((rindex=0; rindex < max_rindex; rindex++))
    do
        for ((i=2; i < repeat; i++))
        do

            s=`echo "scale=3; ${dr[$windex]}" | bc`
            it=`awk 'NR == '$rindex+1'{print $9}' ${rfile[$windex]}`

            dtd=`awk 'NR == '$rindex+1'{print $8}' ${rfile[$windex]}`
            atdown=`echo "scale=10; ($dtd/${r[$rindex]})" | bc`

            #measured pre-copy time
            tm=`awk 'NR == '$rindex+1'{print $3}' ${rfile[$windex]}`

            ###For  (M/R) x (1-(S/R)^{n+1})/(1-(S/R))###
            #retrive number of iteration executed n
            #it=`awk 'NR == '$rindex+1'{print $9}' ${rfile[$windex]}`
            sr=`echo "scale=3; ($s)/${r[$rindex]}" | bc`
            ito=`echo "scale=15; l(${alpha[$windex]})/l($sr)" | bc -l`
            it=`echo $ito | awk '$1 < 0 {printf("%d",$1*-1)} $1 >=0 {printf("%d",$1)}' | awk '$1 > 29 {print 29} $1 <= 29 {print $1}'`
            #value of S/R is stored in sr
            #predicted pre-copy time
            pt=`echo "scale=8; (${sz[$windex]}/${r[$rindex]}) * (1-${b[$windex]})* ( (1 - ($sr)^$it)/(1- $sr) )" | bc`
            rpt=`echo "$pt > 3 * (${sz[$windex]}/${r[$rindex]})" | bc`
            isgrt=0
            if [ $rpt -eq 1 ]; then
                pt=`echo "scale=3; 3*(${sz[$windex]}/${r[$rindex]})" | bc`
                isgrt=1
            fi
            #calculating prediction error

            tmore=0
            er=`echo "$pt-$tm < 0" | bc`
            if [ $er -eq 1 ]; then
                er=`echo "scale=3; $tm-$pt " | bc`
            else
                er=`echo "scale=3; $pt-$tm " | bc`
                tmore=1
            fi
            per=`echo "scale=3; ($er/$tm)*100" | bc`
            pvol=`echo "scale=3; $pt*${r[$rindex]}" | bc`
            avol=`echo "scale=3; $tm*${r[$rindex]}" | bc`
            vmore=0
            ver=`echo "$pvol-$avol < 0" | bc`
            if [ $ver -eq 1 ]; then
                ver=`echo "scale=3; $avol-$pvol " | bc`
            else
                ver=`echo "scale=3; $pvol-$avol " | bc`
                vmore=1
            fi
            vper=`echo "scale=3; ($ver/$avol)*100" | bc`
            ptdown=`echo "scale=10; (${sz[$windex]}/${r[$rindex]})*((1-${b[$windex]}) * ($sr)^($it+1) + ${b[$windex]})" | bc`
            tptdown=`echo "$ptdown > (${sz[$windex]}/${r[$rindex]})" | bc`
            isgrd=0
            if [ $tptdown -eq 1 ]; then
                ptdown=`echo "scale=3; (${sz[$windex]}/${r[$rindex]})" | bc`
                isgrd=1
            fi
            dmore=0
            der=`echo "$ptdown-$atdown < 0" | bc`
            if [ $der -eq 1 ]; then
                der=`echo "scale=10; $atdown-$ptdown " | bc`
            else
                der=`echo "scale=10; $ptdown-$atdown " | bc`
                dmore=1
            fi
            dper=`echo "scale=3; ($der/$atdown)*100" | bc`


            #printing the measured pre-copy time, predicted, err and percentage of error
            echo ${wname[$windex]}" "$s" "${ratem[$rindex]}" 1.PTpre "$pt" 2.ATpre "$tm" 3.ETpre "$er" 4.PETpre "$per" 5.More "$tmore" 6.s>r:t " $isgrt " 7.PTdown "$ptdown" 8.ATdown "$atdown" 9.ETdown "$der" 10.PETdown "$dper" 11.More "$dmore" 12.s>r:d "$isgrd" 13.PVol "$pvol" 14.AVol "$avol" 15.EVol "$ver" 16.PEVol "$vper" 17.More "$vmore >> infocom-$1.txt

#<<CC
        done
    done
done
./get_mt.sh infocom-$1.txt

./process.sh infocom-$1.txt
<<CC
awk '{print $NF}' detailed-prediction-error-hpdc-$1.txt > prediction-error-percent-hpdc-$1.txt
cat prediction-error-percent-hpdc-$1.txt | sort -n > prediction-error-percent-hpdc-sorted-$1.txt
awk '{c++; print c, $1}' prediction-error-percent-hpdc-sorted-$1.txt > x.txt
mv x.txt prediction-error-percent-hpdc-sorted-$1.txt
./get_cdf.sh prediction-error-percent-hpdc-sorted-$1.txt > hpdc-cdf-error-percent-$1.txt

awk '{i=NF-2; print $i}' detailed-prediction-error-hpdc-$1.txt > prediction-error-value-hpdc-$1.txt
cat prediction-error-value-hpdc-$1.txt | sort -n > prediction-error-value-hpdc-sorted-$1.txt
awk '{c++; print c, $1}' prediction-error-value-hpdc-sorted-$1.txt > x.txt
mv x.txt prediction-error-value-hpdc-sorted-$1.txt
./get_cdf.sh prediction-error-value-hpdc-sorted-$1.txt > hpdc-cdf-error-value-hpdc-$1.txt

<<CC

cat prediction-error-percent-base.txt | sort -n > prediction-error-percent-sorted-base.txt
awk '{c++; print c, $1}' prediction-error-percent-sorted-base.txt > x.txt
mv x.txt prediction-error-percent-sorted-base.txt
rm prediction-error-percent-base.txt
./get_cdf.sh prediction-error-percent-sorted-base.txt > hpdc-cdf-error-percent-base-$1.txt


cat prediction-error-percent-infocom.txt | sort -n > prediction-error-percent-sorted-infocom.txt
awk '{c++; print c, $1}' prediction-error-percent-sorted-infocom.txt > x.txt
mv x.txt prediction-error-percent-sorted-infocom.txt
rm prediction-error-percent-infocom.txt
./get_cdf.sh prediction-error-percent-sorted-infocom.txt > hpdc-cdf-error-percent-infocom-$1.txt

cat prediction-error-percent-effective-rate.txt | sort -n > prediction-error-percent-sorted-effective-rate.txt
awk '{c++; print c, $1}' prediction-error-percent-sorted-effective-rate.txt > x.txt
mv x.txt prediction-error-percent-sorted-effective-rate.txt
rm prediction-error-percent-effective-rate.txt
./get_cdf.sh prediction-error-percent-sorted-effective-rate.txt > hpdc-cdf-error-percent-effective-rate-$1.txt


cat prediction-error-value-base.txt | sort -n > prediction-error-value-sorted-base.txt
awk '{c++; print c, $1}' prediction-error-value-sorted-base.txt > x.txt
mv x.txt prediction-error-value-sorted-base.txt
rm prediction-error-value-base.txt
./get_cdf.sh prediction-error-value-sorted-base.txt > hpdc-cdf-error-value-base-$1.txt


cat prediction-error-value-infocom.txt | sort -n > prediction-error-value-sorted-infocom.txt
awk '{c++; print c, $1}' prediction-error-value-sorted-infocom.txt > x.txt
mv x.txt prediction-error-value-sorted-infocom.txt
rm prediction-error-value-infocom.txt
./get_cdf.sh prediction-error-value-sorted-infocom.txt > hpdc-cdf-error-value-infocom-$1.txt

cat prediction-error-value-effective-rate.txt | sort -n > prediction-error-value-sorted-effective-rate.txt
awk '{c++; print c, $1}' prediction-error-value-sorted-effective-rate.txt > x.txt
mv x.txt prediction-error-value-sorted-effective-rate.txt
rm prediction-error-value-effective-rate.txt
./get_cdf.sh prediction-error-value-sorted-effective-rate.txt > hpdc-cdf-error-value-effective-rate-$1.txt

CC
