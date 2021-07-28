package com.reemii.bdmap;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.baidu.trace.api.track.DistanceResponse;
import com.google.gson.Gson;
import com.reemii.bdmap.trace.TraceConfig;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * BdmapPlugin 实现了ActivityAware和ServiceAware注册时实现了这两个接口注册之后会自动实例化
 */
public class BdmapPlugin implements MethodChannel.MethodCallHandler, FlutterPlugin {
    public static final String TAG = BdmapPlugin.class.getSimpleName();

    public static final String CHANNEL_NAME = "com.reemii.driver.channel.bamap";
    public static final String EVENT_CHANNEL = "com.reemii.driver.channel.bamap.event";

    private MethodChannel mMethodChannel;
    private EventChannel.EventSink mEventSink;
    private FlutterPluginBinding mFlutterPluginBinding;

    private BDLocationClient mBDLocationClient;
    private TraceManager mTraceManager;

    public BdmapPlugin() {
        Log.e(TAG, "BdmapPlugin:初始化 ");
    }

    //新版本使用:注入到插件表中是自动调用
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.e(TAG, "onAttachedToEngine: ");
        mFlutterPluginBinding = flutterPluginBinding;
        setupChannel(flutterPluginBinding.getBinaryMessenger(), flutterPluginBinding.getApplicationContext());

        // 1. 初始化定位工具类
        mBDLocationClient = new BDLocationClient(flutterPluginBinding.getApplicationContext());
        // 2. 初始化轨迹工具类
        mTraceManager = new TraceManager(flutterPluginBinding.getApplicationContext());
    }

    //FlutterEngine调用
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        teardownChannel();

        // 1. 释放定位相关
        mBDLocationClient.release();
        // 2. 释放轨迹相关
        mTraceManager.release();
    }

    private void setupChannel(BinaryMessenger messenger, Context context) {
        new EventChannel(messenger, EVENT_CHANNEL).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                mEventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {

            }
        });
        mMethodChannel = new MethodChannel(messenger, CHANNEL_NAME);
        mMethodChannel.setMethodCallHandler(this::onMethodCall);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        Log.e(TAG, "onMethodCall: " + call.method);
        switch (call.method) {
            case "initBdLocation":
                //初始化位置服务
                mBDLocationClient.start();
                mBDLocationClient.register(new BDLocationClient.onLocationCallBack() {
                    @Override
                    public void onLocation(RMLocation rmLocation) {
                        //传递位置数据给flutter保存
                        Map<String, String> data = new HashMap<>();
                        data.put("location", new Gson().toJson(rmLocation));
                        if (mEventSink != null) mEventSink.success(data);
                    }
                });
                break;
            case "initTrace":
                //初始化收集
                Map<String, String> params = (Map<String, String>) call.arguments;
                String staffId = params.get("staffId");
                String traceId = params.get("traceId");

                //初始化鹰眼轨迹服务
                mTraceManager.initTrace(new TraceConfig(staffId,
                        Long.parseLong(traceId),
                        4,
                        8,
                        mFlutterPluginBinding.getApplicationContext()));
                break;

            case "startTrace":
                //开始轨迹服务
                mTraceManager.startTrace(new TraceConfig.ITraceService.TraceCallback() {
                    @Override
                    public void onTraceOpenSuccess() {
                        Log.e(TAG, "onTraceOpenSuccess: ");
                        //查询一次轨迹
                        queryTraceMile();
                        Map<String, Object> data = new HashMap<>();
                        data.put("msg", "轨迹服务开启成功！");
                        if (mEventSink != null) mEventSink.success(data);
                    }

                    @Override
                    public void onTraceOpenFailed(int code, String msg) {
                        Log.e(TAG, "onTraceOpenFailed: " + code + msg);
                        Map<String, Object> data = new HashMap<>();
                        data.put("msg", "轨迹服务开启失败！");
                        if (mEventSink != null) mEventSink.success(data);
                    }
                });
                break;
            case "startGather":
                //开始收集
                mTraceManager.startGather(new TraceConfig.ITraceService.GatherCallback() {
                    @Override
                    public void onGatherSuccess() {
                        Log.e(TAG, "onGatherSuccess: ");
                        if (result == null) return;
                        try {
                            result.success(true);
                        } catch (Exception e) {
                                e.printStackTrace();
                        }
                    }

                    @Override
                    public void onGatherFailed(int code, String msg) {
                        Log.e(TAG, "onGatherFailed: ");
                        if (result == null) return;
                        try {
                            result.success(false);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                    }
                });
                break;
            case "stopTrace":
                //停止估计服务
                mTraceManager.stopTrace();
                break;
            case "stopGather":
                //停止估计收集
                mTraceManager.stopGather();
                break;
            case "query":
                //查询里程
                queryTraceMile();
                break;

            case "stopLocation":
                mBDLocationClient.stop();
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void queryTraceMile() {
        //查询轨迹
        mTraceManager.queryMile(new TraceConfig.ITraceService.QueryCallback() {
            @Override
            public void onQueryResult(DistanceResponse distanceResponse) {
                Map<String, Object> data = new HashMap<>();
                data.put("miles", distanceResponse.getDistance());
                mEventSink.success(data);
            }
        });
    }

    //销毁
    private void teardownChannel() {
        mMethodChannel.setMethodCallHandler(null);
        mMethodChannel = null;
    }


}
