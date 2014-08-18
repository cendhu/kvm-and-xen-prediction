source all-results.sh

for ((windex=0; windex<55; windex++))
do
   echo "scale=6; 50/(${sz[$windex]}*256)" | bc
done
