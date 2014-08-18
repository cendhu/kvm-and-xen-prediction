./get_overall_dirty_count $1 0 $2 0 > tmp.txt
u=`awk '{s+=$2; c++} END {print (s/(c))/1}' tmp.txt`
total_dirty=`awk '{print $1}' tdp.txt`
awk '{print $1, $2/'$total_dirty'.0}' dirty_frequency.txt > access_rate.txt
awk '{print $1, $2*'$u'}' access_rate.txt > dirty_rate.txt
awk '{s+=$2; print s}' dirty_rate.txt > sum
awk '{s+=$1} END {print s/(1024*256)}' sum

