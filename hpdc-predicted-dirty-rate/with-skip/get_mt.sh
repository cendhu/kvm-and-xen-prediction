awk '{
    p=$5+$17;
    a=$7+$19;
    if (p>a)
        er=p-a;
    else
        er=a-p;
    per=(er/a)*100;
    print $0,"35.Pmt "p,"37.Amt "a,"39.Emt "er,"41.PEmt "per
}' $1 > tmp.txt
mv tmp.txt $1
