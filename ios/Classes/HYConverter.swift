//
//  HYConverter.swift
//  AFNetworking
//
//  Created by 冰空花束 on 2020/3/4.
//

import Foundation
import UIKit

let app = SwiftBdmapPlugin.instance!

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let STATUS_BAR_HEIGHT = UIApplication.shared.statusBarFrame.size.height  //状态条高度

// 上传位置key
let TRACE_KEY = "naviPath"
let NAVI_INFO_KEY = "naviInfo"

//UserDefaults
let TY_USERDEFAULTS_MOBILE = "mobile"  //保存的手机号
let TY_USERDEFAULTS_PASSWORD = "password"  //保存的密码
let TY_USERDEFAULTS_TOKEN = "token"  //保存的token
let TY_USERDEFAULTS_NAME = "name" //保存的name
let TY_USERDEFAULTS_ID = "id"  //保存的staff_id

let TY_USERDEFAULTS_TRAVELING_ID = "traveling_id"  //当前已经发车的id
let TY_USERDEFAULTS_TRAVELING_DATE = "traveling_date"  //当前已经发车的date
let TY_USERDEFAULTS_TRAVELING_JSON = "traveling_json"  //当前已经发车的详细json
let TY_USERDEFAULTS_LONGITUDE = "longitude"  //经度
let TY_USERDEFAULTS_LATITUDE = "latitude" //纬度

let TY_USERDEFAULTS_INITIAL_SAVED_DATE = "initial_saved_date"  //行程开始时的日期
//let TY_USERDEFAULTS_ACCOUNTING_MODEL_ARRAY = "accounting_model_array"  //全局计费模型
let TY_USERDEFAULTS_LATEST_SAVED_DATE = "latest_saved_date"  //上一次接收到鹰眼轨迹查询的日期

let TY_COMPETE_ORDER_SUCCESS_NOTIFICATION = "compete_order_success_notification" //抢单成功通知

let TY_ORDER_CANCEL_NOTIFICATION = "order_cancel_notification" // 订单被取消通知

let TY_FACE_VERIFICATION_SUCCEED_NOTIFICATION = "face_verification_succeed_notification" // 身份验证成功

let TY_DRIVER_OFFLINE_NOTIFICATION = "driver_offline_notification"


