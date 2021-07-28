import 'dart:async';

import 'package:flutter/services.dart';

typedef EventHandler(dynamic eventData);

class Bdmap {
  static MethodChannel _channel;
  static EventChannel _eventChannel;

  // 工厂模式
  factory Bdmap() => _getInstance();

  static Bdmap _getInstance() {
    if (_instance == null) {
      _instance = new Bdmap._internal();
    }
    return _instance;
  }

  static Bdmap get instance => _getInstance();
  static Bdmap _instance;

  //需要在最开始初始化！！！！！
  void addEventHandler(EventHandler eventHandler) {
    _eventChannel.receiveBroadcastStream().listen((data) {
      eventHandler(data);
    });
  }

  Bdmap._internal() {
    // 初始化
    _channel = MethodChannel('com.reemii.driver.channel.bamap');
    _eventChannel = EventChannel('com.reemii.driver.channel.bamap.event');
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  //初始化轨迹追踪
  void initBdLocation() async {
    await _channel.invokeMethod('initBdLocation');
  }

  Future<String> initTrace({String traceId, String staffId}) async {
    return await _channel
        .invokeMethod("initTrace", {'traceId': traceId, 'staffId': staffId});
  }

  //开启鹰轨迹
  void startTrace() async {
    await _channel.invokeMethod("startTrace");
  }

  //开始收集
  Future<bool> startGatherTrace() async {
    return await _channel.invokeMethod("startGather");
  }

  //停止收集
  void stopGatherTrace() async {
    return await _channel.invokeMethod("stopGather");
  }

  //停止服务
  void stopTrace() async {
    await _channel.invokeMethod("stopTrace");
  }

  void stopLocation() async {
    await _channel.invokeMethod("stopLocation");
  }

  //查询轨迹
  void queryTrace() async {
    return await _channel.invokeMethod("query");
  }
}
