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

enum MissionState {
    case uploaded
    case running
    case paused
    case editing
}

class FlyNavigationViewController : UIViewController {
    private var navigationView: FlyNavigationView!
    
    private var previousMissionState: MissionState?

    // Observer properties
    private var missionState: MissionState? /*{
        didSet {
            if allowedTransitions.contains(where: { $0 == oldValue && $1 == missionState }) {
                for listener in stateListeners {
                    listener?(missionState)
                }
            }
        }
    }*/
    
    // Notyfier properties
    var stateListeners: [((_ state: MissionState?) -> Void)?] = []

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        setUp()
    }
    
    func setUp(){
        navigationView = FlyNavigationView()
        registerListeners()
        view = navigationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
}

// Private methods
extension FlyNavigationViewController {
    @objc private func delayExecution() {
        Environment.commandService.executeMissionCommand(.start)
    }
    
    /**
     * 根据表示获取天气类型
     * @param skycon
     * @return
     */
    func getSkycon(_ skycon:String) -> String {
        var resultSky:String = ""
        switch skycon {
            case "CLEAR_DAY":
                resultSky = "晴"
            case "CLEAR_NIGHT":
                resultSky = "晴"
            case "PARTLY_CLOUDY_DAY":
                resultSky = "多云"
            case "PARTLY_CLOUDY_NIGHT":
                resultSky = "多云"
            case "CLOUDY":
                resultSky = "阴"
            case "WIND":
                resultSky = "大风"
            case "HAZE":
                resultSky = "雾霾"
            case "RAIN":
                resultSky = "雨"
            case "SNOW":
                resultSky = "雪"
            default:
                resultSky = ""
        }
        return resultSky
    }
    
    /**
     * 获取小时级别的天气类型
     * @param skycon
     * @param intensity
     * @return
     */
    func getHourWeatherType(skycon:String, intensity:Double) ->String {
        var resultSky:String = getSkycon(skycon)
        if ("雨" == resultSky || "雪" == resultSky) {
            if (intensity < 0.25) {
                resultSky = "小" + resultSky;
            } else if (intensity >= 0.25 && intensity < 0.35) {
                resultSky = "中" + resultSky;
            } else if (intensity >= 0.35 && intensity <= 0.50) {
                resultSky = "大" + resultSky;
            } else {
                resultSky = "暴" + resultSky;
            }
        }
        return resultSky;
    }
    
    /**
     * 获取风力等级   彩云天气返回的数据风速为  公里/小时   需要将值转化为m/s
     * @param temp
     * @return
     */
    func getWindLevel(temp:Double) -> String {
        let windSpeed:Double = temp * 1000 / 3600;
        var windLevel:String
        if (windSpeed >= 0 && windSpeed < 0.3) {
            windLevel = "0级"
        } else if (windSpeed >= 0.3 && windSpeed < 1.6) {
            windLevel = "1级"
        } else if (windSpeed >= 1.6 && windSpeed < 3.4) {
            windLevel = "2级"
        } else if (windSpeed >= 3.4 && windSpeed < 5.5) {
            windLevel = "3级"
        } else if (windSpeed >= 5.5 && windSpeed < 8.0) {
            windLevel = "4级"
        } else if (windSpeed >= 8.0 && windSpeed < 10.8) {
            windLevel = "5级"
        } else if (windSpeed >= 10.8 && windSpeed < 13.9) {
            windLevel = "6级"
        } else if (windSpeed >= 13.9 && windSpeed < 17.2) {
            windLevel = "7级"
        } else if (windSpeed >= 17.2 && windSpeed < 20.8) {
            windLevel = "8级"
        } else if (windSpeed >= 20.8 && windSpeed < 24.5) {
            windLevel = "9级"
        } else if (windSpeed >= 24.5 && windSpeed < 28.5) {
            windLevel = "10级"
        } else if (windSpeed >= 28.5 && windSpeed < 32.7) {
            windLevel = "11级"
        } else {
            windLevel = "12级"
        }
        return windLevel
    }
    
    /**
     * 获取风向，0表示正北方   顺时针
     * @param direction
     * @return
     */
    func getWindDirection(direction:Double) -> String {
        var windDirection:String = ""
        if (direction >= 22.5 && direction < 67.5) {
            windDirection = "东北风"
        } else if (direction >= 67.5 && direction < 112.5) {
            windDirection = "东风"
        } else if (direction >= 112.5 && direction < 157.5) {
            windDirection = "东南风"
        } else if (direction >= 157.5 && direction < 202.5) {
            windDirection = "南风"
        } else if (direction >= 202.5 && direction < 247.5) {
            windDirection = "西南风"
        } else if (direction >= 247.5 && direction < 292.5) {
            windDirection = "西风"
        } else if (direction >= 292.5 && direction < 337.5) {
            windDirection = "西北风"
        } else {
            windDirection = "北风"
        }
        return windDirection
    }
    
    private func submitTask2Svr(_ taskCode:String, count:Int,
                                surveyType:String, surveyContent:String,
                                acreage:Double, boundaryId:String,
                                monitorTime:String, userId:String,
                                startTime:Int, endTime:Int,
                                wind:String, temperature:String,
                                humidity:String, weatherType:String,
                                   completionHandler: @escaping (Bool) -> ()){
        
        let userId:String = "65"
        let missionType:String = "1"
        //let urlSubmitTask:String = "/task/uploadTask?code=\(taskCode)&count=\(count)" +
        //    "&surveyType=\(surveyType)&surveyContent=\(surveyContent)" +
        //    "&acreage=\(acreage)&boundaryId=\(boundaryId)" +
        //    "&monitorTime=\(monitorTime)&userId=\(userId)" +
        //    "&startTime=\(startTime)&endTime=\(endTime)" +
        //    "&wind=\(wind)&temperature=22" +
        //    "&humidity=60%&weatherType=\(weatherType)"
        let urlSubmitTask:String = "/task/uploadTask?code=ID20201104080747&count=29&surveyType=xiaomai&surveyContent=&acreage=10.0&boundaryId=160439521440079300116815000&monitorTime=2020-11-04 08:08:54&userId=65&startTime=1604448432&endTime=1604448534&wind=aabbcc&temperature=22&humidity=60&weatherType=qing"
        
        let baseURL = "/task/uploadTask"
        let queryCode = URLQueryItem(name: "code", value: "ID20201104080747")
        let queryCount = URLQueryItem(name: "count", value: String(count))
        let querySurveyType = URLQueryItem(name: "surveyType", value: surveyType)
        let querySurveyContent = URLQueryItem(name: "surveyContent", value: "")
        let queryAcreage = URLQueryItem(name: "acreage", value: "10.0")
        let queryBoundaryId = URLQueryItem(name: "boundaryId", value: boundaryId)
        
        let queryMonitorTime = URLQueryItem(name: "monitorTime", value: monitorTime)
        let queryUserId = URLQueryItem(name: "userId", value: userId)
        let queryStartTime = URLQueryItem(name: "startTime", value: String(startTime))
        let queryEndTime = URLQueryItem(name: "endTime", value: String(endTime))
        
        let queryWind = URLQueryItem(name: "wind", value: wind)
        let queryTemperature = URLQueryItem(name: "temperature", value: temperature)
        let queryHumidity = URLQueryItem(name: "humidity", value: humidity)
        let queryWeatherType = URLQueryItem(name: "weatherType", value: weatherType)
        
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = [queryCode, queryCount, querySurveyType,
                                    querySurveyContent, queryAcreage, queryBoundaryId,
                                    queryMonitorTime, queryUserId, queryStartTime,
                                    queryEndTime, queryWind, queryTemperature,
                                    queryHumidity, queryWeatherType]
        let reqURL = urlComponents.url!
        
        let auth:WebiiAuthSignatureUtil = WebiiAuthSignatureUtil()
        let authedUrl:String = auth.genUrlAuth(url: reqURL.absoluteString)
        
        // create post request
        let url:URL? = URL(string: authedUrl)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode("just body")
        request.httpBody = jsonData
        
        //request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

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
        /*
        HTTP.POST(authedUrl) { response in
            if let err = response.error{
                print ("error: \(err.localizedDescription)")
                completionHandler(false)
                return
            }
            print ("opt finished: \(response.description)")
            let respData:Data! = response.data
            print ("ret: \(String(describing: respData))")
            
            if let json = try? JSONSerialization.jsonObject(with: respData!, options: []) as? [String: Any],
                let code = json["code"] as? String,
                let data = json["data"] as? [[String:Any]]{
                if (code == "000000"){
                    completionHandler(true)
                }else{
                    print (respData ?? "")
                    completionHandler(false)
                }
            }
        }*/
    }
    
    
    func registerListeners() {
        navigationView.buttonSelected = { id, isSelected in
            switch id {
                case .aircraft:
                    if Environment.flyMapViewController.trackAircraft(isSelected) {
                        //self.navigationView.deselectButton(with: .user)
                    } else {
                        self.navigationView.deselectButton(with: .aircraft)
                    }
            case .start:
                let coordinates = Environment.flyMapViewController.missionCoordinates()
                if Environment.commandService.setMissionCoordinates(coordinates) {
                    Environment.commandService.executeMissionCommand(.upload)
                }
                break
            case .pause:
                Environment.commandService.executeMissionCommand(.pause)
                break
            case .resume:
                Environment.commandService.executeMissionCommand(.resume)
                break
            case .stop:
                Environment.commandService.executeMissionCommand(.stop)
                break
            }
        }

        Environment.locationService.aircraftLocationListeners.append({ location in
            if location == nil {
                self.navigationView.deselectButton(with: .aircraft)
            }
        })
        
        Environment.commandService.commandResponded = { id, success in
            if success {
                switch id {
                    case .upload:
                        self.missionState = MissionState.uploaded
                        self.perform(#selector(self.delayExecution), with: nil, afterDelay: 5)
                        
                    case .start:
                        self.missionState = MissionState.running
                    case .pause:
                        self.missionState = MissionState.paused
                    case .resume:
                        self.missionState = MissionState.running
                    case .stop:
                        self.missionState = MissionState.editing
                }
            } else {
                self.missionState = MissionState.editing
            }
        }
        // 任务开始时调用
        Environment.commandService.missionStarted = {
            //self.missionState = MissionState.editing
            // 记录任务开始时间
            let  now =  NSDate ()
            let  timeInterval: TimeInterval  = now.timeIntervalSince1970
            TaskUtil.startTime = Int (timeInterval)
            
        }
        // 任务完成时调用
        Environment.commandService.missionFinished = { success in
            print ("missionFinished.")
            //self.missionState = MissionState.editing
            // 记录任务结束时间
            let  now =  Date ()
            let  dformatter =  DateFormatter ()
            dformatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"
            let monitorTime = dformatter.string(from: now)
            let  timeInterval: TimeInterval  = now.timeIntervalSince1970
            TaskUtil.endTime = Int (timeInterval)
            
            if let center = Environment.flyMapViewController.missionPolygon?.center {
                let  now =  NSDate ()
                let  timeInterval: TimeInterval  = now.timeIntervalSince1970
                let urlWeather:String = "https://api.caiyunapp.com/v2/3AN0aEo1OyJzrowF/\(center.longitude),\(center.latitude)/weather.jsonp?begin=\(TaskUtil.endTime ?? Int (timeInterval))";
                /*
                HTTP.GET(urlWeather) { response in
                    if let err = response.error{
                        print ("error: \(err.localizedDescription)")
                        return
                    }
                    let respData:Data! = response.data
                    if let json = try? JSONSerialization.jsonObject(with: respData!, options: []) as? [String: Any]{
                        let weather:Weather? = Weather(json:json)
                        let weatherType:String = self.getHourWeatherType(skycon:weather?.result?.realtime?.skycon ?? "", intensity:weather?.result?.realtime?.precipitation?.local?.intensity ?? 0)
                        let temperature:String = String.init(format: "%d", weather?.result?.realtime?.temperature ?? 0 + 0.5)
                        let humidity:String = String.init(format: "%d%%", weather?.result?.realtime?.humidity ?? 0 * 100 + 0.5)
                        let precipitation:String = String.init(format:"%fmm", weather?.result?.daily?.precipitation?[0].max ?? 0)
                        let wind:String = self.getWindLevel(temp: weather?.result?.realtime?.wind?.speed ?? 0) + "-" + self.getWindDirection(direction: weather?.result?.realtime?.wind?.direction ?? 0)
                        
                        let temperatureX:TemperatureX? = weather?.result?.daily?.temperature?[1]
                        let temperatureSection:String = String.init(format:"%d～%d", temperatureX?.min ?? 0 + 0.5, temperatureX?.max ?? 0 + 0.5)
                        
                        self.submitTask2Svr(TaskUtil.taskCode ?? "", count:TaskUtil.mediaFileList.count,
                                            surveyType:"小麦", surveyContent:"",
                                            acreage:10.0, boundaryId:TaskUtil.boundaryId ?? "",
                                            monitorTime:monitorTime, userId:"65",
                                            startTime:TaskUtil.startTime ?? 0, endTime:TaskUtil.endTime ?? 0,
                                            wind:wind, temperature:temperature,
                                            humidity:humidity, weatherType:weatherType,
                                               completionHandler: { (success:Bool) in
                            if success {
                                print("Successed to submitTask2Svr")
                            } else {
                                print("Failed to submitTask2Svr")
                            }
                        })
                        return
                    }
                }*/
                
                self.submitTask2Svr(TaskUtil.taskCode ?? "", count:TaskUtil.mediaFileList.count,
                                    surveyType:"小麦", surveyContent:"",
                                    acreage:10.0, boundaryId:TaskUtil.boundaryId ?? "",
                                    monitorTime:monitorTime, userId:"65",
                                    startTime:TaskUtil.startTime ?? 0, endTime:TaskUtil.endTime ?? 0,
                                    wind:"3级-北风", temperature:"22",
                                    humidity:"60%", weatherType:"晴",
                                       completionHandler: { (success:Bool) in
                    if success {
                        print("Successed to submitTask2Svr")
                    } else {
                        print("Failed to submitTask2Svr")
                    }
                })
            }
        }
    }
}
