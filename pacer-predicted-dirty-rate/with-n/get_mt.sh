awk '{
    p=$5+$17;
    a=$7+$19;
    if (p>a)
        er=p-a;
    else
        er=a-p;
    per=(er/a)*100;
    pv=(p*$3)/8.0;
    av=(a*$3)/8.0;

    if (pv>av)
        erv=pv-av;
    else
        erv=av-pv;
    perv=(er/a)*100;
    if (pv>av)
        more=1
    for (i=1; i<=28; i++)
        printf $i" ";
        printf pv" 14.AVol "av" 15.EVol "erv" 16.PEVol "perv" 17.More "more" 35.Pmt "p" 37.Amt "a" 39.Emt "er" 41.PEmt "per; printf("\n");}' $1 > tmp.txt
mv tmp.txt $1
