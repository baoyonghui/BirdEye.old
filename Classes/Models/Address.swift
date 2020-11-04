//
//  Address.swift
//  Bird14
//
//  Created by yu xiaohe on 2020/11/1.
//

import Foundation

struct Location{
    var lng:Double?
    var lat:Double?
}

extension Location {
    init?(json: [String: Any]) {
        guard let lng = json["lng"] as? Double,
            let lat = json["lat"] as? Double
        else {
            return nil
        }
        self.lng = lng
        self.lat = lat
    }
}

struct AddressComponent{
    var city:String?
    var direction:String?
    var distance:String?
    var district:String?
    var province:String?
    var street:String?
    var street_number:String?
}

extension AddressComponent {
    init?(json: [String: Any]) {
        guard let city = json["city"] as? String,
            let direction = json["direction"] as? String,
            let distance = json["distance"] as? String,
            let district = json["district"] as? String,
            let province = json["province"] as? String,
            let street = json["street"] as? String,
            let street_number = json["street_number"] as? String
        else {
            return nil
        }
        self.city = city
        self.direction = direction
        self.distance = distance
        self.district = district
        self.province = province
        self.street = street
        self.street_number = street_number
    }
}

struct AddressResult{
    var location:Location?
    var formatted_address:String?
    var business:String?
    var addressComponent:AddressComponent?
    var cityCode:Int?
}

extension AddressResult {
    init?(json: [String: Any]) {
        guard let formatted_address = json["formatted_address"] as? String,
              let business = json["business"] as? String,
              let cityCode = json["cityCode"] as? Int,
              let locationJson = json["location"] as? [String: Any],
              let addressComponentJSON = json["addressComponent"] as? [String: Any]
        else {
            return nil
        }
        let location:Location? = Location(json: locationJson)
        let addressComponent:AddressComponent? = AddressComponent(json:addressComponentJSON)
        
        self.location = location
        self.formatted_address = formatted_address
        self.business = business
        self.addressComponent = addressComponent
        self.cityCode = cityCode
    }
}

struct Address{
    var status:String?
    var result:AddressResult?
}
extension Address {
    init?(json: [String: Any]) {
        guard let status = json["status"] as? String,
            let resultJSON = json["result"] as? [String: Any]
        else {
            return nil
        }

        let result:AddressResult? = AddressResult(json:resultJSON)
        self.status = status
        self.result = result
    }
}
