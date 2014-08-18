for ((i=1; i<=9; i++))
do
    cat dr-.$i.txt | awk 'BEGIN{print "dr=("} {print "\"("$9"/256.0)\""} END{print ")"}' > defined-dr.sh
    ./predict-pre-copy-time.sh
    mv hnh-cdf-error-infocom.txt hnh-cdf-error-infocom-.$i.txt
    mv hnh-cdf-error-effective-rate.txt hnh-cdf-error-effective-rate-.$i.txt

done


cat dr-1.txt | awk 'BEGIN{print "dr=("} {print "\"("$9"/256.0)\""} END{print ")"}' > defined-dr.sh
./predict-pre-copy-time.sh
mv hnh-cdf-error-infocom.txt hnh-cdf-error-infocom-1.txt
mv hnh-cdf-error-effective-rate.txt hnh-cdf-error-effective-rate-1.txt
