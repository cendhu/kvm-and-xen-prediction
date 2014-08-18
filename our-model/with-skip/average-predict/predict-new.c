#include<stdio.h>
#include<math.h>
#include<stdlib.h>

#define MAX_Un_COUNT 20

float Um, mwwss;
float Un[MAX_Un_COUNT];
float GUn;
int Un_count;

float get_Un(float time)
{
    if (time >= 10)
        return Un[Un_count-1];
    //float remaining_time = time - int(time);
    float value = Un[int(time)];
    //if (time > 1)
    //    value = - remaining_time * (value - Un[int(time)-1]);
    return value;
}

float predict_dirty(float time)
{
    float dirty_data = 0.0;
    float no_100ms = time * 10;
    GUn = get_Un(time);
    if (no_100ms < 1)
        dirty_data = Um * no_100ms;
    else
        dirty_data = Um + (no_100ms - 1.0) * GUn;

    if (dirty_data < mwwss)
        return dirty_data;
    return mwwss;
}

float get_eligible_pages(float Ctime, float Ptime, float Cdirty, float Pdirty, int p)
{
    float dirtyCP = 0.0;
    dirtyCP = predict_dirty(Ctime+Ptime);
    p && printf("Cdirty %f Pdirty %f dirtyCP %f\n", Cdirty, Pdirty, dirtyCP);
    return Cdirty + Pdirty - dirtyCP;
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
    /*if (argc != 13) {
        printf("\nUsage: ./predict vmsize rate measured_iter measured_tpre Um UnCount Un1-P mwwss print dtd\n");
        printf("\nvmsize in MB \nrate in Mbps\nmeasured_tpre in secs\nSm UnCount Un1-P mwwss in #pages\ndtd in MB");
        return -1;
    }*/
    int vmsize = atoi(argv[1]);
    float rate = atoi(argv[2]);
    int measured_iter = atoi(argv[3]);
    float measured_tpre = atof(argv[4]);
    Um = atoi(argv[5]) / 256.0;
    Un_count = atoi(argv[6]);
    for (int i = 0; i < Un_count; i++)
        Un[i] = atoi(argv[i+7]) / 256.0;
    mwwss = atoi(argv[6+Un_count+1]) / 256.0;
    p = atoi(argv[6+Un_count+2]);
    int sgr = 0;
    float measured_dtd = atof(argv[6+Un_count+3]);

    vol = vmsize;
    rate /= 8;
    float dirty = 0.0;
    float w = 0.0;
    float edp = 0.0;
    float pre_per_iter_time = 0.0;
    float pre_vol = 0.0;
    for (iter = 1; iter <= 29; iter++) {
        per_iter_time = vol/rate;
        dirty = predict_dirty(per_iter_time);
        if (iter > 1) {
            edp = get_eligible_pages(per_iter_time, pre_per_iter_time, dirty, pre_vol, p);
            p && printf("edp %f\n", edp);
            w = 0.8078 * edp*256 - 215.0473;

        } else {
            w = 0.7121 * dirty*256 + 4070.4908;
            //w = 0.6589 * dirty*256 + 5689.4908;
            /*
            if (per_iter_time >= 10)
                w = 7.9119 * ((vol*256)/(rate*8*3.2) - (((dirty-Um)/Un[Un_count-1])+1)) + 0.7078*dirty*256 + 3249.4232;
            else
                w = 7.9119 * ((vol*256)/(rate*8*3.2) - (((dirty-Um)/Un[int(per_iter_time)])+1)) + 0.7078*dirty*256 + 3249.4232;
            */
        }
        w = w / 256.0;
        p && printf("vol %f dirty %f w %f\n", vol, dirty, w);
        if (w > dirty) {
            w = dirty-4;;
        }
        vol = vol - w;
        pre_per_iter_time = per_iter_time;
        per_iter_time = vol/rate;
        total_sent += vol;
        tpre += per_iter_time;
        //vol = predict_dirty(per_iter_time);
        vol = dirty;
        pre_vol = vol;
        p && printf("iter %d time %f dirty %f skip %f\n", iter, per_iter_time, dirty*256, w*256);

        if (total_sent >= 3 * vmsize) {
            sgr = 1;
            break;
        }
        if (vol*256 <= 50)
            break;
    }


    float tdown = vol/rate;
    float measured_tdown = measured_dtd/rate;

    dirty = 0.0;
    w = 0.0;
    edp = 0.0;
    pre_per_iter_time = 0.0;
    pre_vol = 0.0;
    per_iter_time = 0.0;
    vol = vmsize;
    total_sent = 0;
    float tpre_less = 0.0;
    for (iter = 1; iter <= 29; iter++) {
        per_iter_time = vol/rate;
        dirty = predict_dirty(per_iter_time);
        if (iter > 1) {
            edp = get_eligible_pages(per_iter_time, pre_per_iter_time, dirty, pre_vol, p);
            p && printf("edp %f\n", edp);
            w = 0.8078 * edp*256 - 215.0473;

        } else {
            w = 0.7121 * dirty*256 + 4070.4908;
            //w = 0.6589 * dirty*256 + 5689.4908;
            //w = 7.9119 * ((vol*256)/(rate*8*3.2) - (((dirty-Um)/Un[Un_count-1])+1)) + 0.7078*dirty*256 + 3249.4232;
            //w = 8.1 * (vmsize*256)/(rate*8*3.2) + 0.7084*dirty*256 + 1827.023;
        }
        w = w / 256.0;
        p && printf("vol %f dirty %f w %f\n", vol, dirty, w);
        if (w > dirty) {
            w = dirty-4;;
        }
        vol = vol - w;
        per_iter_time = vol/rate;
        total_sent += vol;
        tpre_less += per_iter_time;
        pre_per_iter_time = per_iter_time;
        vol = predict_dirty(per_iter_time);
        //vol = dirty;
        pre_vol = vol;
        p && printf("iter %d time %f dirty %f skip %f\n", iter, per_iter_time, dirty*256, w*256);

        if (total_sent >= 3 * vmsize) {
            sgr = 1;
            break;
        }
        if (vol*256 <= 50)
            break;
    }

    float tdown_less = vol/rate;
    tpre = (tpre + tpre_less)/2;
    tdown = (tdown + tdown_less)/2;

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
