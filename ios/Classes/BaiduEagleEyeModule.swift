//
//  BaiduEagleEyeModule.swift
//  bdmap
//
//  Created by 冰空花束 on 2020/3/4.
//

import UIKit
import AMapLocationKit
import BaiduTraceSDK

//鹰眼模型类协议
protocol KiraBaiduEagleEyeModuleDelegate {
    func receiveDistance(_ distance: Double)
}

@objc class KiraBaiduEagleEyeModule: NSObject {
    //单例
    var delegate: KiraBaiduEagleEyeModuleDelegate?
    var locService: AMapLocationManager?
    var locationTimer: Timer?  //每隔10s获取一次经纬度，根据是否在行程当中这个状态，来判定是上传到app服务器还是添加到鹰眼entity point当中。
    var isOnTrip: Bool?  //判定当前是否处于行程状态，用于决定是将位置上传到app服务器还是添加到鹰眼entity point当中。
    var isDriverOnline: Bool?  //用于判定当前司机是否处于接单状态，true为接单状态，然后根据isOnTrip状态决定怎样处理位置，false为休息状态，不再接单。
    var isEagleEyeEntitySuccessfullyRegistered: Bool?  //用于判定当前是否已经成功注册了该名称的鹰眼实体
    var staffId: String?
    var traceId: String?
    fileprivate var locParams: String?
    
//    @objc static var _instance: KiraBaiduEagleEyeModule?
    
    static var sharedInstance: KiraBaiduEagleEyeModule?
    
    @objc static func initShareInstance () {
        let instance = KiraBaiduEagleEyeModule()
        AMapServices.shared()?.apiKey = app.amapKey
        instance.locService = AMapLocationManager()
        instance.locService?.delegate = instance
//        instance.locService?.
        instance.locService?.allowsBackgroundLocationUpdates = true
        instance.locService?.distanceFilter = 200
        instance.locationTimer = Timer.scheduledTimer(timeInterval: 15, target: instance, selector: #selector(KiraBaiduEagleEyeModule.uploadFlutterLoc), userInfo: nil, repeats: true)
        sharedInstance = instance
//        BTK
    }
    
    //开启鹰眼功能
    func startEagleEye() {
//        let instance = KiraBaiduEagleEyeModule.sharedInstance
        let op = BTKStartServiceOption.init(entityName: self.staffId)
        BTKAction.sharedInstance()?.startService(op, delegate: self)
    }
    
    //关闭鹰眼功能
    func stopEagleEye() {
        BTKAction.sharedInstance()?.stopService(self)
    }
    
    //开始采集
    func startGather() {
        BTKAction.sharedInstance()?.startGather(self)
    }
    
    //停止采集
    func stopGather() {
        BTKAction.sharedInstance()?.stopGather(self)
    }
    
    //开启定位服务
    @objc func startLocationService() {
//        let instance = KiraBaiduEagleEyeModule.sharedInstance
        //iOS 9（不包含iOS 9） 之前设置允许后台定位参数，保持不会被系统挂起
        self.locService!.pausesLocationUpdatesAutomatically = false

        //iOS 9（包含iOS 9）之后新特性：将允许出现这种场景，同一app中多个locationmanager：一些只能在前台定位，另一些可在后台定位，并可随时禁止其后台定位。
        if UIDevice.current.systemVersion._bridgeToObjectiveC().doubleValue >= 9.0 {
            self.locService!.pausesLocationUpdatesAutomatically = true
        }

        //开始持续定位
        self.locService?.startUpdatingLocation()
        self.locationTimer?.fire()
        
//        instance.locService
//            instance.manager?.startLocationService()
    }
    
    //关闭定位服务，这个接口暂时开放，以防止特殊情况需要在外部直接停止位置更新
    func stopLocationService() {
        
        if self.locationTimer != nil {
            locService?.stopUpdatingLocation()
            self.locationTimer?.invalidate()
            self.locationTimer = nil
        }
        print("定位类被释放了")
//        manager.stopLocationService()
    }
    
    //第一次加载，初始化，根据缓存中存储的信息来确定该如何设置KiraBaiduEagleEyeModule的各类状态
    func initEagleEye(staffId: String) {
        self.staffId = staffId
        let sop = BTKServiceOption.init(ak: app.baiduMapKey, mcode: app.mcode, serviceID: app.baiduEagleEyeServiceId, keepAlive: true)
        BTKAction.sharedInstance()?.initInfo(sop)
//        let instance = KiraBaiduEagleEyeModule.sharedInstance
//        self.staffId = staffId
    }
    
    func queryTraceMile() {
//        let instance = KiraBaiduEagleEyeModule.sharedInstance!
        let endTime = UInt(Date().timeIntervalSince1970)
        let startTime = endTime - 12 * 60 * 60
        
        let queryOption = BTKQueryTrackProcessOption()
        queryOption.denoise = true
        queryOption.mapMatch = true
        queryOption.transportMode = .TRACK_PROCESS_OPTION_TRANSPORT_MODE_DRIVING
        
        let query = BTKQueryTrackDistanceRequest(entityName: self.staffId, startTime: startTime, endTime: endTime, isProcessed: true, processOption: queryOption, supplementMode: .TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_DRIVING, serviceID: app.baiduEagleEyeServiceId, tag: 12)
        BTKTrackAction.sharedInstance()?.queryTrackDistance(with: query, delegate: self)
    }
    
    
    deinit {
        print("==========定位类已被释放============")
        stopLocationService()
    }
    
}

extension KiraBaiduEagleEyeModule: BTKTraceDelegate {
    func onStartService(_ error: BTKServiceErrorCode) {
        print("开启鹰眼轨迹 code:\(error.rawValue)")
    }
    
    func onStopService(_ error: BTKServiceErrorCode) {
        print("关闭鹰眼轨迹 code:\(error.rawValue)")
    }
    
    func onStartGather(_ error: BTKGatherErrorCode) {
        print("开始收集轨迹 code:\(error.rawValue)")
    }
    
    func onStopGather(_ error: BTKGatherErrorCode) {
        print("结束轨迹采集 code:\(error.rawValue)")
    }
    
}

extension KiraBaiduEagleEyeModule: AMapLocationManagerDelegate {
    
    func amapLocationManager(_ manager: AMapLocationManager!, doRequireLocationAuth locationManager: CLLocationManager!) {
        locationManager.requestAlwaysAuthorization()
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!) {
//        let instance = KiraBaiduEagleEyeModule.sharedInstance
        print("位置信息获取")
        let baiduPoint = JZLocationConverter.gcj02 (toBd09:  CLLocationCoordinate2D(latitude: location?.coordinate.latitude ?? 0.0, longitude: location?.coordinate.longitude ?? 0.0))
        
        let param: [String: Any] = [
            "lat" : Double(baiduPoint.latitude),
            "lng" : Double(baiduPoint.longitude),
            "direction": Double(location.course),
            "alt": Double(location.altitude),
            "speed": Double(location.speed)
        ]
        let params: String = convertDictionaryToJSONString(dict: param as NSDictionary)
        self.locParams = params
        print("定位 ================》〉》〉》〉》〉")
        print(params)
        app.eventSink?(["location": params])
    }
    
    // 传回flutter位置信息
    @objc func uploadFlutterLoc() {
        if self.locParams == nil {
            self.locService?.startUpdatingLocation()
            return
        }
        app.eventSink?(["location": self.locParams])
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
//        let instance = KiraBaiduEagleEyeModule.sharedInstance
        print(error as Any)
    }
    
}

extension KiraBaiduEagleEyeModule: BTKTrackDelegate {
    func onQueryTrackDistance(_ response: Data!) {
        do {
            let data = try JSONSerialization.jsonObject(with: response, options: .mutableContainers)
            print("里程数据！！！")
            print(data)
            if data is [String: Any] {
                let distance = (data as? [String: Any])?["toll_distance"]
                app.eventSink?(["miles": distance])
            }
        } catch let err {
            print(err)
        }
        
    }
}
