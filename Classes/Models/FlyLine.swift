//
//  FlyLine.swift
//  Bird14
//
//  Created by yu xiaohe on 2020/10/31.
//

import Foundation
import MapKit

class FlyLine {
    var id:Int?
    var userId:String?//登录用户
    var name:String?//航线名称
    
    var boundaryId:String?//地块id
    var date:String?//监测日期
    var address:String?//地址
    var province:String? //省
    var city:String? //市
    var district:String? //县
    var cityCode:String? //城市码
    var type:Int? //类型 1航线 2定距 3航点
    var overlap:Int? //垄宽
    var space:Int? //垄宽
    var height:Int? //高度
    var speed:Int? //速度
    
    var points:[[Double]] = []//航点数组
    var weather:String?//天气
    var cropId:String?//作物id
    var cropVarietyId:String?//品种id
    var imageUrl:String?//图片地址
    var status:Int? //状态 1可用2不可用

    var lat:Double?
    var lng:Double?
    var boundary:[[Double]] = []//边界数组
    var acreage:Double?
    
    init(id: Int?, boundaryId: String?) {
        self.id = id
        self.boundaryId = boundaryId
    }
}
