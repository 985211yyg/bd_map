package com.reemii.bdmap.trace;

import android.content.Context;

import com.baidu.trace.api.track.DistanceResponse;

/**
 * Author: yyg
 * Date: 2019-12-27 11:20
 * Description:
 */
//轨迹设置
public class TraceConfig {
    public String staffId;
    public long servicesId;
    public int mGatherInterval = 3; //获取位置间隔
    public int mPackInterval = 6;  //回传间隔
    public Context mAppContext;

    public TraceConfig() {
    }

    public TraceConfig(String staffId, long servicesId, int gatherInterval, int packInterval, Context appContext) {
        this.staffId = staffId;
        this.servicesId = servicesId;
        mGatherInterval = gatherInterval;
        mPackInterval = packInterval;
        mAppContext = appContext;
    }

    public interface ITraceService {
        void initTrace(TraceConfig config);

        void startTrace(TraceCallback traceCallback);

        void stopTrace();

        void startGather(GatherCallback gatherCallback);

        void stopGather();

        void queryMile(QueryCallback queryCallback);

        void release();


        interface TraceCallback {
            void onTraceOpenSuccess();

            void onTraceOpenFailed(int code, String msg);
        }

        interface GatherCallback {
            void onGatherSuccess();

            void onGatherFailed(int code, String msg);

        }

        interface QueryCallback {
            void onQueryResult(DistanceResponse distanceResponse);
        }
    }
}