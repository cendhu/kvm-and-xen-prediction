echo "dr=("
awk '{print "\"("($2*.5*1024)*256"/256)\""}' $1
echo ")"
