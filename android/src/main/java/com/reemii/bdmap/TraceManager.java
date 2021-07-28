package com.reemii.bdmap;

import android.content.Context;
import android.util.Log;

import com.baidu.trace.LBSTraceClient;
import com.baidu.trace.Trace;
import com.baidu.trace.api.track.DistanceRequest;
import com.baidu.trace.api.track.DistanceResponse;
import com.baidu.trace.api.track.OnTrackListener;
import com.baidu.trace.api.track.SupplementMode;
import com.baidu.trace.model.OnTraceListener;
import com.baidu.trace.model.ProcessOption;
import com.baidu.trace.model.PushMessage;
import com.baidu.trace.model.TransportMode;
import com.reemii.bdmap.trace.TraceConfig;

import javax.security.auth.login.LoginException;

public class TraceManager implements OnTraceListener, TraceConfig.ITraceService {
    private final static String TAG = TraceManager.class.getSimpleName();
    private LBSTraceClient mTraceClient;
    private Trace mTrace;
    private TraceCallback mTraceCallback;
    private GatherCallback mGatherCallback;
    private DistanceRequest mDistanceRequest;

    public TraceManager(Context context) {
        mTraceClient = new LBSTraceClient(context);
    }

    @Override
    public void initTrace(TraceConfig config) {
        Log.e(TAG, "初始化鹰眼服务: ");
        mTrace = new Trace(config.servicesId, config.staffId, false);
        mDistanceRequest = new DistanceRequest(123456, config.servicesId, config.staffId);
        mTraceClient.setInterval(config.mGatherInterval, config.mPackInterval);
        //此处设置了监听后面的就不用设置
        mTraceClient.setOnTraceListener(this);
    }


    //开启轨迹服务  已经在mainActivity中提前开启
    @Override
    public void startTrace(TraceCallback traceCallback) {
        Log.e(TAG, "开启鹰眼服务 ");
        mTraceCallback = traceCallback;
        mTraceClient.startTrace(mTrace, null);
    }

    //开启收集轨迹，需要检查服务是否开启，没有开启则等待服务开启
    @Override
    public void startGather(GatherCallback gatherCallback) {
        Log.e(TAG, "开始收集轨迹 ");
        mGatherCallback = gatherCallback;
        //检查服务
        startTrace(new TraceCallback() {
            @Override
            public void onTraceOpenSuccess() {
                Log.e(TAG, "onTraceOpenSuccess: 开启服务成功！");
                mTraceClient.startGather(null);
            }

            @Override
            public void onTraceOpenFailed(int code, String msg) {
                Log.e(TAG, "onTraceOpenFailed: 开启服务失败");
                //再次重试开启服务
//                mTraceClient.startTrace(mTrace, null);
            }
        });
    }


    //停止收集轨迹
    @Override
    public void stopGather() {
        Log.e(TAG, "stopGather:停止收集 ");
        if (mTraceClient != null) {
            mTraceClient.stopGather(null);
        }
    }

    //停止轨迹服务
    @Override
    public void stopTrace() {
        // 停止采集
        if (mTraceClient != null) {
            mTraceClient.stopGather(null);
            mTraceClient.stopTrace(mTrace, null);
        }
    }

    //查询当前行驶的轨迹
    @Override
    public void queryMile(QueryCallback queryCallback) {
        if (mTraceClient == null) { return; }
        // 开始时间(单位：秒)
        long startTime = System.currentTimeMillis() / 1000 - 12 * 60 * 60;
        // 结束时间(单位：秒)
        long endTime = System.currentTimeMillis() / 1000;
        // 设置开始时间
        mDistanceRequest.setStartTime(startTime);
        // 设置结束时间
        mDistanceRequest.setEndTime(endTime);
        // 设置需要纠偏
        mDistanceRequest.setProcessed(true);
        // 创建纠偏选项实例
        ProcessOption processOption = new ProcessOption();
        // 设置需要去噪
        processOption.setNeedDenoise(true);
        // 设置需要抽稀
        processOption.setNeedVacuate(true);
        // 设置需要绑路
        processOption.setNeedMapMatch(true);
        // 设置精度过滤值(定位精度大于100米的过滤掉)
        processOption.setRadiusThreshold(100);
        // 设置交通方式为驾车
        processOption.setTransportMode(TransportMode.driving);
        // 设置纠偏选项
        mDistanceRequest.setProcessOption(processOption);
        // 设置里程填充方式为驾车
        mDistanceRequest.setSupplementMode(SupplementMode.driving);

        // 查询里程
        mTraceClient.queryDistance(mDistanceRequest, new OnTrackListener() {
            @Override
            public void onDistanceCallback(DistanceResponse distanceResponse) {
                queryCallback.onQueryResult(distanceResponse);
            }
        });

    }

    @Override
    public void release() {
        stopGather();
        stopTrace();
    }


    //================鹰眼自己的回调===========
    @Override
    public void onBindServiceCallback(int code, String s) {
        Log.e(TAG, "onBindServiceCallback: " + code + s);
    }

    //服务开启回调
    @Override
    public void onStartTraceCallback(int code, String s) {
        /**
         * 调用startTrace()来判断。   code=0
         * 若返回"服务已开启"，则表明服务正在运行；  code 10006
         * 若返回"success"，则表明之前服务未在运行，但此时已被开启；
         * 若返回"服务正在开启"，则表明之前服务未在运行，现在正在开启过程中，需等待服务开启完毕。
         * 0：成功
         * 10000：请求发送失败
         * 10001：服务开启失败
         * 10002：参数错误
         * 10003：网络连接失败
         * 10004：网络未开启
         * 10005：服务正在开启
         * 10006：服务已开启
         * 10007：服务正在停止
         */
        Log.e(TAG, "onStartTraceCallback: " + code + s);
        if (code == 0 || code == 10006) {
            if (mTraceCallback != null) {
                mTraceCallback.onTraceOpenSuccess();
            }

        } else {
            if (mTraceCallback != null) {
                mTraceCallback.onTraceOpenFailed(code, s);
            }
        }

    }

    //开始收集 0成功  12003已经开启
    @Override
    public void onStartGatherCallback(int code, String s) {
        Log.e(TAG, "onStartGatherCallback: " + code + s);
        if (code == 0 || code == 12003) {
            if (mGatherCallback != null) {
                mGatherCallback.onGatherSuccess();
            }
        } else {
            if (mTraceCallback != null) {
                mGatherCallback.onGatherFailed(code, s);
            }
        }
    }


    @Override
    public void onStopTraceCallback(int code, String s) {
        Log.e(TAG, "onStopTraceCallback: " + code + s);

    }


    @Override
    public void onStopGatherCallback(int i, String s) {
        Log.e(TAG, "onStopGatherCallback: " + i + s);
    }

    @Override
    public void onPushCallback(byte b, PushMessage pushMessage) {

    }

    @Override
    public void onInitBOSCallback(int i, String s) {
        Log.e(TAG, "onInitBOSCallback: " + i + s);
    }

}
