import Flutter
import UIKit

public class SwiftBdmapPlugin: NSObject, FlutterPlugin {
    public static let CHANNEL_NAME:String  = "com.reemii.driver.channel.bamap"
    public static let EVENT_CHANNEL:String  = "com.reemii.driver.channel.bamap.event"
    
    static var instance: SwiftBdmapPlugin?
    
    var isTwoDayTravel: Bool?  //标明查询历史轨迹的两个时间段是否为同一天
    var isQueryFirstDay: Bool? //标识当前是否在查询第一天的历史轨迹
    var isQuerySecondDay: Bool?  //标识当前是否在查询第二天的历史轨迹
    var firstDistance: Double?  //第一天轨迹行驶距离
    var secondDistance: Double?  //第二天轨迹行驶距离
    
    var initialSavedDate: Date?  //行程开始时的日期
    //@property (nonatomic, strong) NSArray *accountingModelArray;  //全局计费模型，用于专车司机端专车计费
    var latestSavedDate: Date?  //上一次接收到鹰眼轨迹轨迹的日期
    let amapKey: String = "99c8c6e43433f2d24e0874cb514d93e7"
    let baiduMapKey: String = "8fPsuIdV12PFKipp3RAgj70v0xVlMrVL"
    var baiduEagleEyeServiceId: UInt = 206755
    var isPlayingCompeteInfo: Bool?
    var tokenExpire: Bool?
    let mcode: String = "com.reemii.bjxing.special.driver"
    fileprivate var messenger: (NSObject & FlutterBinaryMessenger)?
    var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: messenger)
        instance = SwiftBdmapPlugin(messenger: (messenger as! (NSObject & FlutterBinaryMessenger)))
        registrar.addMethodCallDelegate(instance!, channel: channel)
    }
    
    init(messenger: (NSObject & FlutterBinaryMessenger)?) {
        self.messenger = messenger
        super.init()
        let evenChannal = FlutterEventChannel.init(name: SwiftBdmapPlugin.EVENT_CHANNEL, binaryMessenger: messenger!)
        evenChannal.setStreamHandler(self)
        print("原生定位模块注册初始化完成")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //    result("iOS " + UIDevice.current.systemVersion)
        print(call)
        switch call.method {
        case "initBdLocation":
            print("初始化位置服务")
            //初始化位置服务
            KiraBaiduEagleEyeModule.initShareInstance()
            KiraBaiduEagleEyeModule.sharedInstance?.startLocationService()
            break;
            
        case "initTrace":
            let params : [String: Any?] = call.arguments as! [String: Any?]
            print(params)
            //               self.baiduEagleEyeServiceId = UInt(params["traceId"] as! String) ?? 0
            KiraBaiduEagleEyeModule.sharedInstance?.initEagleEye(staffId: params["staffId"] as! String)
            result("初始化成功！")
            break;
            
        case "startTrace":
            //开始轨迹服务
            KiraBaiduEagleEyeModule.sharedInstance?.startEagleEye()
            break;
        case "startGather":
            //开始收集
            KiraBaiduEagleEyeModule.sharedInstance?.startGather()
            KiraBaiduEagleEyeModule.sharedInstance?.queryTraceMile()
            result(true)
            break;
        case "stopTrace":
            //停止估计服务
            KiraBaiduEagleEyeModule.sharedInstance?.stopEagleEye()
            break;
        case "stopGather":
            KiraBaiduEagleEyeModule.sharedInstance?.stopGather()
            //停止估计收集
            break;
        case "query":
            //查询里程
            KiraBaiduEagleEyeModule.sharedInstance?.queryTraceMile()
            break;
            
        case "stopLocation":
            KiraBaiduEagleEyeModule.sharedInstance?.stopLocationService()
//            if KiraBaiduEagleEyeModule.sharedInstance != nil {
//                KiraBaiduEagleEyeModule.sharedInstance = nil
//            }
            break;
        default:
            break;
        }
    }
}


extension SwiftBdmapPlugin: FlutterStreamHandler {
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("清除event")
        eventSink = nil
        return nil
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("获取event")
        eventSink = events
        return nil
    }
}
