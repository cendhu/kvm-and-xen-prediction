dir=(
"hot-non-hot-dirty-rate-prediction"
"hpdc-predicted-dirty-rate"
"infocom"
"pacer-predicted-dirty-rate"
"sample-rate-dirty-prediction"
)

mdir=5

for ((i=0; i<mdir; i++))
do
    cp $1 ${dir[$i]}/with-n/
done
cp $1 our-model/
