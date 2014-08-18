echo "dr=("
awk '{print "\"("$4"/256.0)\""}' $1
echo ")"
