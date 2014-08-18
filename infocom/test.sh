source all-results.sh

awk 'BEGIN{windex=0} {print $1, ($2*'${sz['windex']}')*128; windex++;}' $1
