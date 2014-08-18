source all-results.sh

source defined-dr-new.sh

ratem=("100" "110" "120" "130" "140" "150" "160" "170" "180" "190" "200" "210" "220" "230" "240" "250" "260" "270" "280" "290" "300" "310" "320" "330" "340" "350" "360" "370" "380" "390" "400" "410" "420" "430" "440" "450" "460" "470" "480" "490" "500" "510" "520" "530" "540" "550" "560" "570" "580" "590" "600" "610" "620" "630" "640" "650" "660" "670" "680" "690" "700" "710" "720" "730" "740" "750" "760" "770" "780" "790" "800")
sindex=0
max_windex=55
rindex=1
max_rindex=71
repeat=1
rm -rf our-new-model.txt
rm *.tt
for ((windex=0; windex < max_windex; windex++))
do
    for ((rindex=0; rindex < max_rindex; rindex++))
    do
        for ((i=0; i < repeat; i++))
        do
            #retrive number of iteration executed n
            it=0
            dtd=0

            #measured pre-copy time
            tm=0

            echo "${wname[$windex]} ./predict-new ${sz[$windex]} ${ratem[$rindex]} $it $tm ${Um[$windex]} 10 ${Un1[$windex]} ${Un2[$windex]} ${Un3[$windex]}  ${Un4[$windex]} ${Un5[$windex]} ${Un6[$windex]} ${Un7[$windex]} ${Un8[$windex]}  ${Un9[$windex]}  ${Un10[$windex]} ${mwws[$windex]} 0 $dtd"
            an=`./predict-new ${sz[$windex]} ${ratem[$rindex]} $it $tm ${Um[$windex]} 10 ${Un1[$windex]} ${Un2[$windex]} ${Un3[$windex]}  ${Un4[$windex]} ${Un5[$windex]} ${Un6[$windex]} ${Un7[$windex]} ${Un8[$windex]}  ${Un9[$windex]}  ${Un10[$windex]} ${mwws[$windex]} 0 $dtd`
            echo ${wname[$windex]}" "${Um[$windex]}" "${ratem[$rindex]}" "$an >> ${wname[$windex]}.tt

        done
    done
    awk '{print $1, $3, $5, $17, $5+$17}' ${wname[$windex]}.tt > x
    mv x ${wname[$windex]}.tt
done
#./get_mt.sh our-new-model.txt
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
