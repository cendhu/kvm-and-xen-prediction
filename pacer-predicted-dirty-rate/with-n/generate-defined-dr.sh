echo "dr=("
awk '{print "\"("$2"/256.0)\""}' $1
echo ")"