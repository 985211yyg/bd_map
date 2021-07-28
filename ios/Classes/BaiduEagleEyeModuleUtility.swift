//
//  BaiduEagleEyeModuleUtility.swift
//  bdmap
//
//  Created by 冰空花束 on 2020/3/4.
//

import Foundation
import AFNetworking
import SwiftyJSON
//import BaiduTraceSDK

let KiraBaiduEagleEyeReceiveDistanceNotification = Notification.Name("KiraBaiduEagleEyeReceiveDistanceNotification")

//根据司机端登录之后的手机号，生成对应的鹰眼实体名，类似于Driver_1223423423424
//修改司机端登录之后的staff_id，生成对应的鹰眼实体名，
func generateEntityName() -> String {
    if let staff_id = UserDefaults.standard.value(forKey: TY_USERDEFAULTS_ID) as? String {
        return staff_id
    } else {
        return "DefaultEntity"
    }
    
}

//用于计费秒表中的字符转换
func convertFromIntToTwoDecimal(_ number: Int) -> String {
    if number >= 0 && number <= 9 {
        return "0\(number)"
    } else {
        return "\(number)"
    }
}

//AFHTTPSessionManager单例
extension AFHTTPSessionManager {
    //这种单例适用于百度的web api
    static let sharedInstance: AFHTTPSessionManager = {
        let instance = AFHTTPSessionManager()
        let requestSerializer = AFHTTPRequestSerializer()
        requestSerializer.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        //requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        instance.requestSerializer = requestSerializer
        instance.responseSerializer = AFHTTPResponseSerializer()
        return instance
    }()
    
    //这类单利适用于与app服务器的通信
    static let commonSharedInstance: AFHTTPSessionManager = {
        let sessionManager = AFHTTPSessionManager()
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let responseSerializer = AFHTTPResponseSerializer()
        sessionManager.requestSerializer = requestSerializer
        sessionManager.responseSerializer = responseSerializer
        return sessionManager
    }()
}


typealias Response_Handler = (JSON?, Any?) -> Void

func kiraBaiduNetworkMethod(method: Kira_Network_Method, url: String, param: Any?, handleResponseMethod: @escaping Response_Handler) {
    let sessionManager = AFHTTPSessionManager.sharedInstance
    if method == Kira_Network_Method.post {
        sessionManager.post(url, parameters: param, headers: nil, progress: nil, success: { (_, response) in
            if let data = response as? Data {
                if let json = try? JSON(data: data) {
                    print("\(json)")
                    handleResponseMethod(json, param)
                }
            } else {
                handleResponseMethod(nil, nil)
            }
            
        }, failure: { (_, error) in
            print("kiraNetworkMethod execute failed,the error is \(error)")
            handleResponseMethod(nil, nil)
        })
    } else if method == Kira_Network_Method.get {
        sessionManager.get(url, parameters: param, headers: nil, progress: nil, success: { (_, response) in
            if let data = response as? Data {
                if let json = try? JSON(data: data) {
                    print("\(json)")
                    handleResponseMethod(json, param)
                }
            } else {
                handleResponseMethod(nil, nil)
            }
            
        }, failure: { (_, error) in
            print("kiraNetworkMethod execute failed,the error is \(error)")
            handleResponseMethod(nil, nil)
        })
    } else {
        handleResponseMethod(nil, nil)
    }
    
}

func kiraCommonNetworkMethod(method: Kira_Network_Method, url: String, param: Any?, handleResponseMethod: @escaping Response_Handler) {
    let sessionManager = AFHTTPSessionManager.commonSharedInstance
    if method == Kira_Network_Method.post {
        sessionManager.post(url, parameters: param, headers: nil, progress: nil, success: { (_, response) in
            if let data = response as? Data {
                if let json = try? JSON(data: data) {
                    print("\(json)")
                    handleResponseMethod(json, param)
                }
            } else {
                handleResponseMethod(nil, nil)
            }
            
        }, failure: { (_, error) in
            print("kiraNetworkMethod execute failed,the error is \(error)")
            handleResponseMethod(nil, nil)
        })
    } else if method == Kira_Network_Method.get {
        sessionManager.get(url, parameters: param, headers: nil, progress: nil, success: { (_, response) in
            if let data = response as? Data {
                if let json = try? JSON(data: data) {
                    print("\(json)")
                    handleResponseMethod(json, param)
                }
            } else {
                handleResponseMethod(nil, nil)
            }
            
        }, failure: { (_, error) in
            print("kiraNetworkMethod execute failed,the error is \(error)")
            handleResponseMethod(nil, nil)
        })
    } else {
        handleResponseMethod(nil, nil)
    }
    
}

//百度鹰眼服务添加实体节点
func kiraAddEagleEyeEntityWithName(name: String) {
    
    let param: Any? = [
        "ak" : app.baiduMapKey,
        "service_id" : app.baiduEagleEyeServiceId,
        "entity_name" : name,
        "mcode" : "com.reemii.bjxing.special.driver"
    ]
    kiraBaiduNetworkMethod(method: .post, url: Kira_Url_Add_Entity, param: param, handleResponseMethod: kiraHandleAddEagleEyeEntityResponse)
}

//处理百度鹰眼添加实体节点response
func kiraHandleAddEagleEyeEntityResponse(response: JSON?, originParam: Any?) {
    if response == nil {
        //添加实体节点失败
        print("添加entity失败")
        
        let instance = KiraBaiduEagleEyeModule.sharedInstance!
        instance.isEagleEyeEntitySuccessfullyRegistered = false
        
    } else if response?["status"].int == Baidu_EagleEye_Entity_Exist_Status_Code || response?["status"].int == 0 {
        print("该实体已经存在或创建entity成功")
        
        let instance = KiraBaiduEagleEyeModule.sharedInstance!
        instance.isEagleEyeEntitySuccessfullyRegistered = true
        
    } else {
        //其他类型错误
        print("添加entity失败")
        if let message = response?["message"].string {
            print("错误信息为：\(message)")
        }
        
        let instance = KiraBaiduEagleEyeModule.sharedInstance!
        instance.isEagleEyeEntitySuccessfullyRegistered = false
        
    }
}

//百度鹰眼添加轨迹点
func kiraAddPointToEntity(entityName: String, latitude: Double, longitude: Double) {
    let param = [
        "ak" : app.baiduMapKey,
        "service_id" : app.baiduEagleEyeServiceId,
        "latitude" : latitude,
        "longitude" : longitude,
        "coord_type" : 3, //1为gps经纬度坐标，2为国测局加密经纬度坐标，3为百度加密经纬度坐标
        "entity_name" : entityName,
        "loc_time" : Int(Date().timeIntervalSince1970),
        "mcode" : Bundle.main.infoDictionary?["CFBundleIdentifier"]
    ]
    kiraBaiduNetworkMethod(method: .post, url: Kira_Url_Entity_Add_Point, param: param, handleResponseMethod: kiraHandleAddPointToEntityResponse)
}

//百度鹰眼添加轨迹点response handler
func kiraHandleAddPointToEntityResponse(response: JSON?, originParam: Any?) {
    if response == nil {
        print("添加轨迹点失败")
    } else if response?["status"].int == 0 {
        print("添加轨迹点成功")  //添加轨迹点成功，则立即执行查询历史轨迹操作，获取截止到目前为止，行驶的距离。
        //app?.Kira_Eagle_Eye_End_Date = Date()
        app.latestSavedDate = Date()
        if app.initialSavedDate == nil {
            app.initialSavedDate = (UserDefaults.standard.value(forKey: TY_USERDEFAULTS_TRAVELING_DATE) as? Date) ?? Date()
        }
        kiraGetHistory(start_time: app.initialSavedDate! , end_time: app.latestSavedDate!, entity_name: generateEntityName())
        //kiraGetHistory(start_time: Date().addingTimeInterval(-10 * 60 * 60), end_time: Date(), entity_name: app?.Kira_Eagle_Eye_Entity_Name ?? "")
        
    } else {
        //其他类型错误
        print("添加轨迹点失败")
        if let message = response?["message"].string {
            print("错误信息为：\(message)")
        }
    }
}

//百度鹰眼查询历史轨迹
func kiraGetHistory(start_time: Date, end_time: Date, entity_name: String) {
    let param = [
        "ak" : app.baiduMapKey,
        "service_id" : app.baiduEagleEyeServiceId,
        "start_time" : Int(start_time.timeIntervalSince1970),
        "end_time" : Int(end_time.timeIntervalSince1970),
        "entity_name" : entity_name,
        "is_processed" : 1,  //打开轨迹纠偏
        "process_option" : "need_denoise=1",  //纠偏选项
        "sulement_mode" : "driving",  //里程补偿方式，这里使用最短驾车路线距离补充
        "mcode" : "com.reemii.bjxing.special.driver"
        ] as [String : Any]
    kiraBaiduNetworkMethod(method: .get, url: Kira_Url_Get_History, param: param, handleResponseMethod: kiraGetHistoryResponse)
}

//百度鹰眼查询历史轨迹response handler
func kiraGetHistoryResponse(response: JSON?, originParam: Any?) {
    if response == nil {
        print("查询历史轨迹失败")
        return
    } else if response?["status"].int == 0 {
        //查询历史轨迹成功，后续应该post notification
        if let distance = response?["distance"].double {
            print("查询历史轨迹成功，截止目前，已行驶：\(distance)米")
            //            NotificationCenter.default.post(name: Notification.Name("ReceiveDistanceNotification"), object: ["distance" : distance])
            //这边后面打算用代理来实现
            KiraBaiduEagleEyeModule.sharedInstance!.delegate?.receiveDistance(distance / 1000)
            
        }
        
    } else {
        //其他类型错误
        print("查询历史轨迹失败")
        if let message = response?["message"].string {
            print("错误信息为: \(message)")
        }
    }
}

//将经纬度上传到app服务器，不在行程之中，用于服务器实时记录车辆位置信息
func kiraUploadPositionToServer(_ staffId: String, token: String, longitude: CLLocationDegrees, latitude: CLLocationDegrees) {
    //    #if DEBUG
    //        let url = "http://120.76.29.221:8080/staff/staff/position?token=" + token
    //    #else
    //        let url = "http://tt.jt169.com/staff/staff/position?token=" + token
    //    #endif
    
    //    let url = app.ty_MAIN_URL + "/staff/staff/position?token=" + token
    
    let param: Any? = [
        "staffId" : staffId,
        "lat" : String(latitude),
        "lng" : String(longitude)
    ]
    //    kiraCommonNetworkMethod(method: .post, url: url, param: param, handleResponseMethod: kiraUploadPositionToServerResponse)
}

//经纬度上传到app服务器response handler
func kiraUploadPositionToServerResponse(_ response: JSON?, originParam: Any?) {
    if response == nil {
        print("位置上传服务器失败")
        return
    } else if response?["code"].int == 0 {
        //经纬度上传成功
        print("位置上传服务器成功")
        
    } else {
        //其他类型错误
        print("位置上传服务器失败")
    }
}


func convertDictionaryToJSONString(dict:NSDictionary?)->String {
    let data = try? JSONSerialization.data(withJSONObject: dict!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
    let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
    return jsonStr! as String
}


