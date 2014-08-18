#include<stdio.h>
#include<math.h>
#include<stdlib.h>
float Sm, Sn1n2, Sn, Um, Un, mwwss;

float predict_dirty(float time)
{
    float dirty_data = 0.0;
/*
    if (time >= 1.0 && time <= 2.0) {
        dirty_data = Sm + (time-1.0) * Sn1n2;
    } else if (time > 2.0) {
        dirty_data = Sm + Sn1n2 + (time-2.0) * Sn;
    }
*/
    if (time >= 1.0) {
        dirty_data = Sm + (time-1.0) * Sn;
    }
    else {
        time = time * 10; //getting number of 100 milliseconds
        if (time >= 1.0) {
            dirty_data += Um + (time-1.0) * Un;
        } else {
            dirty_data += time * Um;
        }
    }
    if (dirty_data < mwwss)
        return dirty_data;
    return mwwss;
}

int main(int argc, char *argv[])
{

    int iter = 1;
    double vol = 0.0;
    float tpre = 0.0;
    float per_iter_time = 0.0;
    int total_sent = 0;
    int remaining = 0;
    int p = 0;
    if (argc != 13) {
        printf("\nUsage: ./predict vmsize rate measured_iter measured_tpre Sm Sn1n2 Sn Um Un mwwss print dtd\n");
        printf("\nvmsize in MB \nrate in Mbps\nmeasured_tpre in secs\nSm Sn1n2 Sn Um Un mwwss in #pages\ndtd in MB");
        return -1;
    }
    int vmsize = atoi(argv[1]);
    float rate = atoi(argv[2]);
    int measured_iter = atoi(argv[3]);
    float measured_tpre = atof(argv[4]);
    Sm = atoi(argv[5]) / 256.0;
    Sn1n2 = atoi(argv[6]) / 256.0;
    Sn = atoi(argv[7]) / 256.0;
    Sn = (Sn * 8 + Sn1n2) / 9.0;
    Um = atoi(argv[8]) / 256.0;
    Un = atoi(argv[9]) / 256.0;
    mwwss = atoi(argv[10]) / 256.0;
    p = atoi(argv[11]);
    int sgr = 0;
    float measured_dtd = atof(argv[12]);

    vol = vmsize;
    rate /= 8;

    //for (iter = 1; iter <= measured_iter; iter++) {
    for (iter = 1; iter <= 29; iter++) {
        per_iter_time = vol/rate;
        total_sent += vol;
        tpre += per_iter_time;
        vol = predict_dirty(per_iter_time);
        p && printf("iter %d time %f dirty %f\n", iter, per_iter_time, vol*256);
        if (total_sent >= 3 * vmsize) {
            sgr = 1;
            break;
        }
        if (vol*256 <= 50)
            break;
        /*if(mwwss * 256 == 54677 && iter >= measured_iter)
            break;*/
    }

    float tdown = vol/rate;
    float measured_tdown = measured_dtd/rate;
    int tpre_predict_more = 0;
    int tdown_predict_more = 0;
    int vol_predict_more = 0;

    float tpre_er = 0;
    if (tpre > measured_tpre) {
        tpre_er = tpre - measured_tpre;
        tpre_predict_more = 1;
    }
    else
        tpre_er = measured_tpre - tpre;

    float tdown_er = 0;
    if (tdown > measured_tdown) {
        tdown_er = tdown - measured_tdown;
        tdown_predict_more = 1;
    }
    else
        tdown_er = measured_tdown - tdown;

    float measured_vol = measured_tpre * rate;
    vol = tpre * rate;

    float vol_er = 0;
    if (vol > measured_vol) {
        vol_er = vol - measured_vol;
        vol_predict_more = 1;
    }
    else
        vol_er = measured_vol - vol;


    printf("1.PTpre %f 3.ATpre %f 5.ETpre %f 7.PETpre %f 9.More %d 11.s>r:t %d 13.PTdown %f 15.ATdown %f 17.ETdown %f 19.PETdown %f 21.More %d 23.s>r:d %d 25.PVol %f 27.AVol %f 29.EVol %f 31.PEVol %f 33.More %d", tpre, measured_tpre, tpre_er, (tpre_er/measured_tpre)*100.0, tpre_predict_more, sgr, tdown, measured_tdown, tdown_er, (tdown_er/measured_tdown)*100.0, tdown_predict_more, sgr, vol, measured_vol, vol_er, (vol_er/measured_vol)*100.0, vol_predict_more );
}

/*


        if (vol*256 <= 50 || total_sent >= 3 * vmsize)
            break;
    }
    float er = 0;
    if (tpre > measured_tpre)
        er = tpre - measured_tpre;
    else
        er = measured_tpre - tpre;
    printf("Predicted %f Actual %f Error %f PError %f", tpre, measured_tpre, er, (er/measured_tpre)*100.0);
}
*/
