source all-results.sh

source defined-dr-new.sh

mig_log_name=migration_log_without_skip.txt
rate=("12.5m" "25m" "37.5m" "50m" "62.5m" "75m" "87.5m")
r=("12.5" "25" "37.5" "50" "62.5" "75" "87.5")
ratem=("102" "206" "308" "413" "518" "619" "720")
sindex=0
max_windex=55
rindex=1
max_rindex=7
repeat=1
rm -rf our-new-model.txt

for ((windex=0; windex < max_windex; windex++))
do
    for ((rindex=0; rindex < max_rindex; rindex++))
    do
        for ((i=0; i < repeat; i++))
        do
            #retrive number of iteration executed n
            it=`awk 'NR == '$rindex+1'{print $9}' ${rfile[$windex]}`
            dtd=`awk 'NR == '$rindex+1'{print $8}' ${rfile[$windex]}`

            #measured pre-copy time
            tm=`awk 'NR == '$rindex+1'{print $3}' ${rfile[$windex]}`

            echo "${wname[$windex]} ./predict-new ${sz[$windex]} ${ratem[$rindex]} $it $tm ${Um[$windex]} 10 ${Un1[$windex]} ${Un2[$windex]} ${Un3[$windex]}  ${Un4[$windex]} ${Un5[$windex]} ${Un6[$windex]} ${Un7[$windex]} ${Un8[$windex]}  ${Un9[$windex]}  ${Un10[$windex]} ${mwws[$windex]} 0 $dtd"
            an=`./predict-new ${sz[$windex]} ${ratem[$rindex]} $it $tm ${Um[$windex]} 10 ${Un1[$windex]} ${Un2[$windex]} ${Un3[$windex]}  ${Un4[$windex]} ${Un5[$windex]} ${Un6[$windex]} ${Un7[$windex]} ${Un8[$windex]}  ${Un9[$windex]}  ${Un10[$windex]} ${mwws[$windex]} 0 $dtd`
            echo ${wname[$windex]}" "${Um[$windex]}" "${ratem[$rindex]}" "$an >> our-new-model.txt

        done
    done
done
./get_mt.sh our-new-model.txt
<<CC
awk '{print $NF}' detailed-prediction-error.txt > prediction-error-percent.txt
cat prediction-error-percent.txt | sort -n > prediction-error-percent-sorted.txt
awk '{c++; print c, $1}' prediction-error-percent-sorted.txt > x.txt
mv x.txt prediction-error-percent-sorted.txt
./get_cdf.sh prediction-error-percent-sorted.txt > our-model-cdf-error-percent.txt

awk '{i=NF-2; print $i}' detailed-prediction-error.txt > prediction-error-value.txt
cat prediction-error-value.txt | sort -n > prediction-error-value-sorted.txt
awk '{c++; print c, $1}' prediction-error-value-sorted.txt > x.txt
mv x.txt prediction-error-value-sorted.txt
./get_cdf.sh prediction-error-value-sorted.txt > our-model-cdf-error-value.txt


CC
