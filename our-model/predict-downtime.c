#include<stdio.h>
#include<math.h>
#include<stdlib.h>
float Sm, Sn1n2, Sn, Um, Un1n2, Un, mwwss;

float predict_dirty(float time)
{
    float dirty_data = 0.0;

    if (time >= 1.0 && time <= 2.0) {
        dirty_data = Sm + (time-1.0) * Sn1n2;
    } else if (time > 2.0) {
        dirty_data = Sm + Sn1n2 + (time-2) * Sn;
    }
    else {
        time = time * 10;
        if (time >= 1.0 && time <= 2.0) {
            dirty_data += Um + (time-1.0) * Un1n2;
        } else if (time > 2.0) {
            dirty_data += Um + Un1n2 + (time-2.0) * Un;
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
    if (argc != 14) {
        printf("\nUsage: ./predict vmsize rate measured_iter measured_tpre Sm Sn1n2 Sn Um Un1n2 Un mwwss print dtd\n");
        printf("\nvmsize in MB \nrate in Mbps\nmeasured_tpre in secs\nSm Sn1n2 Sn Um Un1n2 Un mwwss in #pages\ndtd in MB");
        return -1;
    }
    int vmsize = atoi(argv[1]);
    float rate = atoi(argv[2]);
    int measured_iter = atoi(argv[3]);
    float measured_tpre = atof(argv[4]);
    Sm = atoi(argv[5]) / 256.0;
    Sn1n2 = atoi(argv[6]) / 256.0;
    Sn = atoi(argv[7]) / 256.0;
    Um = atoi(argv[8]) / 256.0;
    Un1n2 = atoi(argv[9]) / 256.0;
    Un = atoi(argv[10]) / 256.0;
    mwwss = atoi(argv[11]) / 256.0;
    p = atoi(argv[12]);
    float measured_dtd = atof(argv[13]);

    vol = vmsize;
    rate /= 8;

    //for (iter = 1; iter <= measured_iter; iter++) {
    for (iter = 1; iter <= 29; iter++) {
        per_iter_time = vol/rate;
        total_sent += vol;
        tpre += per_iter_time;
        vol = predict_dirty(per_iter_time);
        p && printf("iter %d time %f dirty %f\n", iter, per_iter_time, vol*256);
        if (vol * 256 <= 50 || total_sent >= 3 * vmsize)
            break;
        if(mwwss * 256 == 54677 && iter >= measured_iter)
            break;
    }
    float er = 0;
    /*if (tpre > measured_tpre)
        er = tpre - measured_tpre;
    else
        er = measured_tpre - tpre;
    printf("Predicted %f Actual %f Error %f PError %f", tpre, measured_tpre, er, (er/measured_tpre)*100.0);
    */
    /*
    float tdown = (vol / 112)*1000;
    if (tdown > measured_tdown)
        er = tdown - measured_tdown;
    else
        er = measured_tdown - tdown;
    printf("Predicted %f Actual %f Error %f PError %f", tdown, measured_tdown, er, (er/measured_tdown)*100.0);
    */

    float dtd = vol;
    if (dtd > measured_dtd)
        er = dtd - measured_dtd;
    else
        er = measured_dtd - dtd;
    printf("Predicted %f Actual %f Error %f PError %f", dtd, measured_dtd, er, (er/measured_dtd)*100.0);



}
