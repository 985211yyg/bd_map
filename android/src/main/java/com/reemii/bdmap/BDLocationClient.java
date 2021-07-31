package com.reemii.bdmap;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import com.baidu.location.BDAbstractLocationListener;
import com.baidu.location.BDLocation;
import com.baidu.location.LocationClient;
import com.baidu.location.LocationClientOption;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.reactivex.Observer;
import io.reactivex.disposables.Disposable;
import rxhttp.wrapper.param.RxHttp;

import static com.reemii.services.protect.ProtectService.CHANNEL_ID;


/**
 * Created by yyg on 2018/10/19 ,10:29
 */
public class BDLocationClient {

    public static final String TAG = BDLocationClient.class.getSimpleName();
    private LocationClient mLocationClient;
    private LocationUploadCallback mLocationUploadCallback;
    private static final String CHANNEL_ID = "location";


    public BDLocationClient(Context context) {
        mLocationClient = new LocationClient(context);
        LocationClientOption option = new LocationClientOption();
        option.setLocationMode(LocationClientOption.LocationMode.Hight_Accuracy);
        option.setCoorType("bd09ll");  //坐标类型
        option.setScanSpan(6000); //定位时间间隔
        option.setOpenGps(true); //使用gps
        option.setIsNeedAddress(false); //可选，设置是否需要地址信息，默认不需要
        option.setIsNeedLocationDescribe(true); //可选，设置是否需要地址描述
        option.setLocationNotify(false); //可选，设置是否当GPS有效时按照1S/1次频率输出GPS结果，默认false
        option.setIgnoreKillProcess(false);  //是否杀死服务
        option.setIsNeedLocationPoiList(true); //可选，默认false，设置是否需要POI结果，可以在BDLocation.getPoiList里得到
        option.SetIgnoreCacheException(false);
        option.setNeedDeviceDirect(true); //需要设备方向
//        option.setWifiCacheTimeOut(5 * 60 * 1000);
        option.setEnableSimulateGps(false); //可选，设置是否收集Crash信息，默认收集，即参数为false
        mLocationClient.setLocOption(option);
        //定位会回调监听
        mLocationUploadCallback = new LocationUploadCallback();

        //开启前台定位服务：
        //获取一个Notification构造器
        // createNotificationChannel(context);

        // Notification.Builder builder;
        // if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        //     builder = new Notification.Builder(context, CHANNEL_ID);
        // } else {
        //     builder = new Notification.Builder(context);
        // }

        // Intent nfIntent = Intent.makeMainActivity(new ComponentName("tech.zhuoguo.trip", "MainActivity"));
        // builder.setContentIntent(PendingIntent.getActivity(context, 0, nfIntent, 0)) // 设置PendingIntent
        //         .setContentTitle("百度定位正在后台定位") // 设置下拉列表里的标题
        //         .setSmallIcon(R.drawable.logo) // 设置状态栏内的小图标
        //         .setContentText("后台定位通知") // 设置上下文内容
        //         .setAutoCancel(true)
        //         .setWhen(System.currentTimeMillis()); // 设置该通知发生的时间
        // Notification notification = builder.build();
        // notification.defaults = Notification.DEFAULT_SOUND; //设置为默认的声音
        // mLocationClient.enableLocInForeground(1001, notification);// 调起前台定位
    }

    private void createNotificationChannel(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = "location service notification";
            String description = "for location service";
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, name, importance);
            channel.setDescription(description);
            NotificationManager notificationManager = context.getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }

    public void register(final onLocationCallBack locationCallBack) {
        Log.e(TAG, "register: ");
        //定位回掉
        mLocationClient.registerLocationListener(new BDAbstractLocationListener() {

            @Override
            public void onReceiveLocation(BDLocation bdLocation) {
                RMLocation rmLocation = new RMLocation();
                rmLocation.lat = bdLocation.getLatitude();
                rmLocation.lng = bdLocation.getLongitude();
                rmLocation.direction = bdLocation.getDirection();
                int errorCode = bdLocation.getLocType();
                if (locationCallBack != null
                        && (errorCode == 61 || errorCode == 66 || errorCode == 161)) {
                    locationCallBack.onLocation(rmLocation);

                }
            }
        });
    }

    public void removeLocationUploadCallback() {
        mLocationClient.unRegisterLocationListener(mLocationUploadCallback);
    }

    public void registerLocationUploadCallback() {
        mLocationClient.registerLocationListener(mLocationUploadCallback);
    }

    public void enableLocInForeground(Notification notification) {
        if (mLocationClient == null) {
            return;
        }
        mLocationClient.enableLocInForeground(10001, notification);
    }

    public void start() {
        if (mLocationClient != null) {
            Log.e("百度SDK定位", "start: ");
            mLocationClient.start();
            registerLocationUploadCallback();
        }
    }

    public void reStart() {
        if (mLocationClient != null) {
            Log.e("百度SDK定位", "重启: ");
            removeLocationUploadCallback();
            mLocationClient.restart();
            registerLocationUploadCallback();
        }
    }

    public void stop() {
        if (mLocationClient != null && mLocationClient.isStarted()) {
            Log.e("百度SDK定位", "stop: ");
            mLocationClient.disableLocInForeground(true);
            mLocationClient.stop();
            removeLocationUploadCallback();
        }
    }

    public void release() {
        stop();
        mLocationClient = null;
    }


    //定位回调
    public interface onLocationCallBack {
        void onLocation(RMLocation rmLocation);
    }


    //定位回调
    public static class LocationUploadCallback extends BDAbstractLocationListener {
        @Override
        public void onReceiveLocation(BDLocation bdLocation) {
            int code = bdLocation.getLocType();
            //上传位置
            if (code == 61 || code == 66 || code == 161) {
                RMLocation rmLocation = new RMLocation();
                rmLocation.lat = bdLocation.getLatitude();
                rmLocation.lng = bdLocation.getLongitude();
                rmLocation.direction = bdLocation.getDirection();
                rmLocation.alt = (float) bdLocation.getAltitude();
                rmLocation.speed = bdLocation.getSpeed();
                //上传位置
//                postLocation(rmLocation);
            }
        }

    }

}

