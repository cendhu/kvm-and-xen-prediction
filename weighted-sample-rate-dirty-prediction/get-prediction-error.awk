$2 ~ /normal/ {
    D=sdr;
    pdp=($11/1000.0) * D;
    if (pdp-$7 >= 1)
        print ((pdp-$7)/$7)*100
    else
        print (($7-pdp)/$7)*100
}
