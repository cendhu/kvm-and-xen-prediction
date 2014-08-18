#include<stdio.h>
#include<math.h>
#include<stdlib.h>
float Sm;

float predict_dirty(float time)
{
    float dirty_data = 0.0;
    float eskipped_data = 0.0;
    dirty_data = time * Sm;
    eskipped_data = 0.362 * (Sm/1180.11) + 0.4342;
    eskipped_data = eskipped_data * dirty_data;
    return dirty_data - eskipped_data;
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
    if (argc != 8) {
        printf("\nUsage: ./predict vmsize rate measured_iter measured_tpre Sm print dtd\n");
        printf("\nvmsize in MB \nrate in Mbps\nmeasured_tpre in secs\nSm 1 for print \ndtd in MB");
        return -1;
    }
    int vmsize = atoi(argv[1]);
    float rate = atoi(argv[2]);
    int measured_iter = atoi(argv[3]);
    int sgr=0;
    float measured_tpre = atof(argv[4]);
    Sm = atoi(argv[5]);
    p = atoi(argv[6]);
    float measured_dtd = atof(argv[7]);

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


    printf("1.PTpre %f 2.ATpre %f 3.ETpre %f 4.PETpre %f 5.More %d 6.s>r:t %d 7.PTdown %f 8.ATdown %f 9.ETdown %f 10.PETdown %f 11.More %d 12.s>r:d %d 13.PVol %f 14.AVol %f 15.EVol %f 16.PEVol %f 17.More %d", tpre, measured_tpre, tpre_er, (tpre_er/measured_tpre)*100.0, tpre_predict_more, sgr, tdown, measured_tdown, tdown_er, (tdown_er/measured_tdown)*100.0, tdown_predict_more, sgr, vol, measured_vol, vol_er, (vol_er/measured_vol)*100.0, vol_predict_more );
}
