awk '{
    if(($3 ~ /102/ && (    $1 ~ /parsec-vips/ ||
                          $1 ~ /tar-1024/ ||
                          $1 ~ /dacapo-fop/ ||
                          $1 ~ /kernel-2/  ||
                          $1 ~ /dacapo-luindex/  ||
                          $1 ~ /bodytrack/ ||
                          $1 ~ /x264/ ||
                          $1 ~ /dell-store-db/ )) ||

                          ($1 ~ /raytrace/ || $1 ~ /blackscholes/))
    {}
    else{
          print $0
      }
}' $1 > y
mv y $1
#value: migration-time
awk '{print $43}' $1 | sort -n | awk '{c++; print c, $1}' > temp.txt
./get_cdf.sh temp.txt > cdf-value-mt-$1
#percent: migration-time
awk '{print $45}' $1 | sort -n | awk '{c++; print c, $1}' > temp.txt
./get_cdf.sh temp.txt > cdf-percent-mt-$1

#value: downtime
awk '{print $21}' $1 | sort -n | awk '{c++; print c, $1}' > temp.txt
./get_cdf.sh temp.txt > cdf-value-dt-$1
#percent: downtime
awk '{print $23}' $1 | sort -n | awk '{c++; print c, $1}' > temp.txt
./get_cdf.sh temp.txt > cdf-percent-dt-$1

#value: pre-copy-time
awk '{print $9}' $1 | sort -n | awk '{c++; print c, $1}' > temp.txt
./get_cdf.sh temp.txt > cdf-value-pct-$1
#percent: pre-copy-time
awk '{print $11}' $1 | sort -n | awk '{c++; print c, $1}' > temp.txt
./get_cdf.sh temp.txt > cdf-percent-pct-$1

#value: volume
awk '{print $33}' $1 | sort -n | awk '{c++; print c, $1}' > temp.txt
./get_cdf.sh temp.txt > cdf-value-vol-$1
#percent: volume
awk '{print $35}' $1 | sort -n | awk '{c++; print c, $1}' > temp.txt
./get_cdf.sh temp.txt > cdf-percent-vol-$1
