//
//  BaiduEagleEyeModuleConstantsAndEnums.swift
//  bdmap
//
//  Created by 冰空花束 on 2020/3/4.
//

import Foundation


////鹰眼参数
//let Baidu_EagleEye_AK = "XYL2Ua86OIO8CRhD8RRx73CpDS06pbyb"  //key
//let Baidu_EagleEye_Service_Id = "134154"  //鹰眼service id
//let Baidu_EagleEye_Entity = "EntityKira"  //实体名
//
////百度地图参数
//let Baidu_Map_AK = "x5uz5RGeVxhbCTKVdioyhIVNjwx24ybm"

let Kira_Url_Add_Entity = "http://api.map.baidu.com/trace/v2/entity/add"  //添加一个新的entity
let Kira_Url_Entity_Add_Point = "http://api.map.baidu.com/trace/v2/track/addpoint"  //为entity添加最新轨迹点
let Kira_Url_Get_History = "http://api.map.baidu.com/trace/v2/track/gethistory"  //查询历史轨迹

let Baidu_EagleEye_Entity_Exist_Status_Code = 3005  //执行添加新的entity返回的状态码，表明改实体已经存在了，无需添加

enum Kira_Network_Method {
    case get
    case post
}
