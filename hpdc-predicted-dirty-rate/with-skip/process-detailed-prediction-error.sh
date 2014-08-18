awk '{print $NF}' detailed-prediction-error-hpdc.txt > prediction-error-percent-hpdc.txt
cat prediction-error-percent-hpdc.txt | sort -n > prediction-error-percent-hpdc-sorted.txt
awk '{c++; print c, $1}' prediction-error-percent-hpdc-sorted.txt > x.txt
mv x.txt prediction-error-percent-hpdc-sorted.txt
./get_cdf.sh prediction-error-percent-hpdc-sorted.txt > hpdc-cdf-error-percent.txt

awk '{i=NF-2; print $i}' detailed-prediction-error-hpdc.txt > prediction-error-value-hpdc.txt
cat prediction-error-value-hpdc.txt | sort -n > prediction-error-value-hpdc-sorted.txt
awk '{c++; print c, $1}' prediction-error-value-hpdc-sorted.txt > x.txt
mv x.txt prediction-error-value-hpdc-sorted.txt
./get_cdf.sh prediction-error-value-hpdc-sorted.txt > hpdc-cdf-error-value-hpdc.txt

