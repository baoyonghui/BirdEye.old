//
//  ControlViewController.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 14.04.20.
//  Copyright © 2020 Evgeny Agamirzov. All rights reserved.
//

import UIKit
import SwiftHTTP
import DJISDK

class NavigationViewController : UIViewController {
    private var navigationView: NavigationView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        setUp()
    }
    
    func setUp(){
        navigationView = NavigationView()
        registerListeners()
        view = navigationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// Private methods
extension NavigationViewController {
    func registerListeners() {
        navigationView.buttonSelected = { id, isSelected in
            switch id {
                case .user:
                    if Environment.mapViewController.trackUser(isSelected) {
                        self.navigationView.deselectButton(with: .aircraft)
                    } else {
                        self.navigationView.deselectButton(with: .user)
                    }
                case .aircraft:
                    if Environment.mapViewController.trackAircraft(isSelected) {
                        self.navigationView.deselectButton(with: .user)
                    } else {
                        self.navigationView.deselectButton(with: .aircraft)
                    }
            case .create:
                Environment.mapViewController.createMissionPolygon()
            case .clear:
                Environment.mapViewController.createMissionPolygon()
            case .submit:
                self.submitFlyLine(completionHandler: { (success:Bool) in
                    if success {
                        print("Successed to submitFlyLine")
                    } else {
                        print("Failed to submitFlyLine")
                    }
                })
            }
        }
        /*Environment.connectionService.listeners.append({ model in
            if model == nil {
                self.navigationView.deselectButton(with: .simulator)
            }
        })*/
        Environment.locationService.aircraftLocationListeners.append({ location in
            if location == nil {
                self.navigationView.deselectButton(with: .user)
            }
        })
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func submitFlyLine(completionHandler: @escaping (Bool) -> ()) {
        let  now =  Date ()
        let  dformatter =  DateFormatter ()
        dformatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"
        let formatedDate = dformatter.string(from: now)
        print ( "当前日期时间：\(formatedDate)" )
         
        //当前时间的时间戳
        let  timeInterval: TimeInterval  = now.timeIntervalSince1970
        let  timeStamp =  Int (timeInterval)
        print ( "当前时间的时间戳：\(timeStamp)" )
        
        let center:CLLocationCoordinate2D = Environment.mapViewController.flyLinePolygon?.center ?? CLLocationCoordinate2D(latitude: 33, longitude: 110)
        let latPart = String(format: "%.6f", center.latitude).replacingOccurrences(of: ".", with: "")
        let lngPart = String(format: "%.6f", center.longitude).replacingOccurrences(of: ".", with: "")
        
        let boundaryId:String = "\(timeStamp)\(latPart)\(lngPart)"
        dformatter.dateFormat =  "yyyyMMddHHmmss"
        let flyLineName = "航线_\(dformatter.string(from: now))"
        
        Environment.mapViewController.screenCapture(completionHandler: { (image:UIImage?) in
            if image != nil {
                print("Successed to screenCapture")
                if let data = image?.pngData() {
                    let filename = self.getDocumentsDirectory().appendingPathComponent(boundaryId + ".png")
                    print ("filename \(filename)")
                    try? data.write(to: filename)
                    
                    let center:CLLocationCoordinate2D = Environment.mapViewController.flyLinePolygon?.center ?? CLLocationCoordinate2D(latitude: 33, longitude: 110)
                    let urlGetAddress:String = "https://api.map.baidu.com/geocoder?location=\(center.latitude),\(center.longitude)" +
                    "&output=json&key=E4805d16520de693a3fe707cdc962045"
                    HTTP.GET(urlGetAddress) { response in
                        
                        var address = "none"
                        var province = "none"
                        var city = "none"
                        var district = "none"
                        var cityCode = "none"
                        
                        if response.error == nil{
                            /*
                             {
                               "status": "OK",
                               "result": {
                                 "location": {
                                   "lng": 113,
                                   "lat": 23
                                 },
                                 "formatted_address": "广东省佛山市禅城区尚塘大街",
                                 "business": "",
                                 "addressComponent": {
                                   "city": "佛山市",
                                   "direction": "",
                                   "distance": "",
                                   "district": "禅城区",
                                   "province": "广东省",
                                   "street": "尚塘大街",
                                   "street_number": ""
                                 },
                                 "cityCode": 138
                               }
                             }
                             */

                            let respData:Data! = response.data
                            if let json = try? JSONSerialization.jsonObject(with: respData!, options: []) as? [String: Any]{
                                let addressInfo:Address? = Address(json:json)
                                address = addressInfo?.result?.formatted_address ?? "none"
                                province = addressInfo?.result?.addressComponent?.province ?? "none"
                                city = addressInfo?.result?.addressComponent?.city ?? "none"
                                district = addressInfo?.result?.addressComponent?.district ?? "none"
                                cityCode = String(format: "%d", addressInfo?.result?.cityCode ?? 0)
                                self.submitFlyLine2Svr(boundaryId, name: flyLineName, date:formatedDate,
                                                       lat:center.latitude, lng:center.longitude,
                                                       image: filename.absoluteString, address: address,
                                                       province: province, city: city, district: district,
                                                       cityCode: cityCode, space:Int(Environment.mapViewController.flyLinePolygon?.gridDistance ?? 12),
                                                       completionHandler: { (success:Bool) in
                                    if success {
                                        print("Successed to submitFlyLine2Svr")
                                        completionHandler(true)
                                    } else {
                                        print("Failed to submitFlyLine2Svr")
                                        completionHandler(false)
                                    }
                                })
                                return
                            }
                        }
                    }
                }
            } else {
                print("Failed to screenCapture")
                completionHandler(false)
            }
        })
    }
    
    private func submitFlyLine2Svr(_ boundaryId:String, name:String, date:String,
                                   lat:Double, lng:Double,
                                   image:String, address:String,
                                   province:String, city:String,
                                   district:String, cityCode:String,
                                   space:Int,
                                   completionHandler: @escaping (Bool) -> ()){
        
        let userId:String = "65"
        let missionType:Int = 1
        let urlSubmitFlyLine:String = "/flyline/saveFlyLine?t=1"
        let auth:WebiiAuthSignatureUtil = WebiiAuthSignatureUtil()
        let authedUrl:String = auth.genUrlAuth(url: urlSubmitFlyLine)
        

        
        struct loc :Encodable{
            var latitude:Double!
            var longitude:Double!
        }
        
        
        let coordinates: [CLLocationCoordinate2D] = Environment.mapViewController.flyLinePolygon?.coordinates ?? []
        let points: [CLLocationCoordinate2D] = Environment.mapViewController.missionCoordinates()
        
        var para_coords:[loc] = []
        for coord in coordinates {
            para_coords.append(loc(latitude: coord.latitude, longitude: coord.longitude))
        }
        var para_points:[loc] = []
        for coord in points {
            para_points.append(loc(latitude: coord.latitude, longitude: coord.longitude))
        }
        
        struct FlyLine :Encodable{
            var userId:String?
            var name: String?
            var boundaryId: String?
            var date: String?
            var address: String?
            var province: String?
            var city: String?
            var district: String?
            var cityCode: String?
            var type: Int?
            var overlap: Int?
            var height: Int?
            var space: Int?
            var speed: Int?
            var points: [loc]?
            var imageUrl: String?
            var cropId: String?
            var cropVarietyId: String?
            var lat: Double?
            var lng: Double?
            var boundary: [loc]?
            var acreage: Double?
        }

        let flyLine:FlyLine = FlyLine(userId: userId, name: name, boundaryId: boundaryId,
                                      date: date, address: address, province: province,
                                      city: city, district: district, cityCode: cityCode,
                                      type: missionType, overlap: 70, height: 70,
                                      space: space, speed: 15, points: para_points,
                                      imageUrl: image, cropId: "小麦", cropVarietyId: "",
                                      lat: lat, lng: lng, boundary: para_coords,
                                      acreage: 30.2)

        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(flyLine)
        let jsonStr = String(decoding: jsonData!, as: UTF8.self)
        print ("request \(jsonStr)")

        // create post request
        let url = URL(string: authedUrl)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // insert json data to the request
        print ("body \(String(describing: jsonData))")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print ("error: \(String(describing: error?.localizedDescription))")
                completionHandler(false)
                return
            }
            print ("opt finished: \(String(describing: response?.description))")
            //let respData:Data! = response?.data
            let jsonStr = String(decoding: data, as: UTF8.self)
            print ("ret: \(jsonStr)")
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let code = json["code"] as? String,
                let data = json["data"] as? [[String:Any]]{
                if (code == "000000"){
                    completionHandler(true)
                }else{
                    print (data )
                    completionHandler(false)
                }
            }
        }

        task.resume()
    }
}
