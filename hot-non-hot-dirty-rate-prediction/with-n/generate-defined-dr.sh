echo "dr=("
awk '{beta=$2; sh=$3; snh=$4; print "\"("beta*sh+(1-beta)*snh"/256.0)\""}' $1
echo ")"
