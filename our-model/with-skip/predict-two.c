#include<stdio.h>
#include<math.h>
#include<stdlib.h>
float Sm, Sn1n2, Sn, Um, Un, mwwss;

float predict_dirty(float time)
{
    float dirty_data = 0.0;

    if (time >= 1.0) {
        dirty_data = Sm + (time-1.0) * Sn;
    } else {
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

float get_eligible_pages(float Ctime, float Ptime, float Cdirty, float Pdirty)
{
    if (Ctime >= 1) {
        if (Pdirty >= mwwss) {
            return Cdirty;
        } else if ((Cdirty + Pdirty) <= mwwss) {
            return Sm - Sn;
        } else if ((Cdirty + Pdirty) > mwwss) {
            return (Cdirty + Pdirty) - mwwss;
        }
    } else if (Ctime < 1) {
        if (Pdirty >= Sm) {
            return Cdirty - (Ctime * Sn);
        } else if ((Cdirty + Pdirty) <= Sm) {
            return Um - Un;
        } else if ((Cdirty + Pdirty) > Sm) {
            float rms = Ctime + Ptime - 1;
            return predict_dirty(rms) - (rms * Sn) + (Um - Un);
        }

    }
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
    Sn = ((Sn * 8) + Sn1n2) / 9.0;
    Um = atoi(argv[8]) / 256.0;
    Un = atoi(argv[9]) / 256.0;
    mwwss = atoi(argv[10]) / 256.0;
    p = atoi(argv[11]);
    float measured_dtd = atof(argv[12]);
    int sgr = 0;

    vol = vmsize;
    rate /= 8;
    float dirty = 0.0;
    float w = 0.0;
    float edp = 0.0;
    float pre_per_iter_time = 0.0;
    float pre_vol = 0.0;
    //for (iter = 1; iter <= measured_iter; iter++) {
    for (iter = 1; iter <= 29; iter++) {

        if (iter == 1 && rate == 102.0/8.0) {
            dirty = mwwss;
        } else {
            per_iter_time = vol/rate;
            dirty = predict_dirty(per_iter_time);
        }
        if (iter > 1) {
            edp = get_eligible_pages(per_iter_time, pre_per_iter_time, dirty, pre_vol);
            if (per_iter_time > 1) {
                w = -0.2289 * (rate*8)/900 + 1.5881 * (dirty/1536) - 1.2391 * (edp/1536.0) + 0.1326 * Sm/dirty + 0.6847;
            } else {
                w = -0.1695 * (rate*8)/900 + 1.7226 * (dirty/1536) + 2.5569 * (edp/1536.0) - 0.0134 * (Um/dirty) + 0.003 * Un/(dirty-Um) + 0.6531;
            }
        } else {
            w = -0.1375 * (rate*8)/900 - 0.7545 * (dirty/1536.0) + 0.3544 * (Sn/(dirty-Sm)) + 0.9862;
        }
        vol = vol - w*dirty;
        per_iter_time = vol/rate;
        total_sent += vol;
        tpre += per_iter_time;
        pre_per_iter_time = per_iter_time;
        pre_vol = vol;
        vol = dirty;
        //vol = predict_dirty(per_iter_time);
        p && printf("iter %d time %f dirty %f skip %f\n", iter, per_iter_time, vol*256, (w*dirty)*256);

        if (total_sent >= 3 * vmsize) {
            sgr = 1;
            break;
        }
        if (vol*256 <= 50)
            break;
    }

    float tdown = vol/rate;

    vol = vmsize;
    dirty = 0.0;
    w = 0.0;
    edp = 0.0;
    pre_per_iter_time = 0.0;
    pre_vol = 0.0;
    float total_sent_2 = 0.0;
    float tpre_2 = 0.0;
    //for (iter = 1; iter <= measured_iter; iter++) {
    for (iter = 1; iter <= 29; iter++) {

        if (iter == 1 && rate == 102.0/8.0) {
            dirty = mwwss;
        } else {
            per_iter_time = vol/rate;
            dirty = predict_dirty(per_iter_time);
        }
        if (iter > 1) {
            edp = get_eligible_pages(per_iter_time, pre_per_iter_time, dirty, pre_vol);
            if (per_iter_time > 1) {
                w = -0.2289 * (rate*8)/900 + 1.5881 * (dirty/1536) - 1.2391 * (edp/1536.0) + 0.1326 * Sm/dirty + 0.6847;
            } else {
                w = -0.1695 * (rate*8)/900 + 1.7226 * (dirty/1536) + 2.5569 * (edp/1536.0) - 0.0134 * (Um/dirty) + 0.003 * Un/(dirty-Um) + 0.6531;
            }
        } else {
            w = -0.1375 * (rate*8)/900 - 0.7545 * (dirty/1536.0) + 0.3544 * (Sn/(dirty-Sm)) + 0.9862;
        }
        vol = vol - w*dirty;
        per_iter_time = vol/rate;
        total_sent_2 += vol;
        tpre_2 += per_iter_time;
        pre_per_iter_time = per_iter_time;
        pre_vol = vol;
        //vol = dirty;
        vol = predict_dirty(per_iter_time);
        p && printf("iter %d time %f dirty %f skip %f\n", iter, per_iter_time, vol*256, (w*dirty)*256);

        if (total_sent_2 >= 3 * vmsize) {
            sgr = 1;
            break;
        }
        if (vol*256 <= 50)
            break;
    }


    float tdown_2 = vol/rate;
    tpre = (tpre + tpre_2) / 2.0;
    tdown = (tdown + tdown_2) / 2.0;
    total_sent = (total_sent + total_sent_2) / 2.0;

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
