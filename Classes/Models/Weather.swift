//
//  Weather.swift
//  Bird14
//
//  Created by yu xiaohe on 2020/11/1.
//

import Foundation

struct Wind {
    /**
     * direction : 192.09
     * speed : 3.57
     */

    var direction:Double?
    var speed:Double?
}

extension Wind {
    init?(json: [String: Any]) {
        guard let direction = json["direction"] as? Double,
            let speed = json["speed"] as? Double
        else {
            return nil
        }
        self.direction = direction
        self.speed = speed
    }
}

struct Local {
    /**
     * status : ok
     * intensity : 0
     * datasource : radar
     */

    var status:String?
    var intensity:Double?
    var datasource:String?
}

extension Local {
    init?(json: [String: Any]) {
        guard let status = json["status"] as? String,
            let intensity = json["intensity"] as? Double,
            let datasource = json["datasource"] as? String
        else {
            return nil
        }
        self.status = status
        self.intensity = intensity
        self.datasource = datasource
    }
}

struct PrecipitationX {
    /**
     * nearest : {"status":"ok","distance":109.77,"intensity":0.1875}
     * local : {"status":"ok","intensity":0,"datasource":"radar"}
     */

    var local:Local?
}

extension PrecipitationX {
    init?(json: [String: Any]) {
        guard let localJSON = json["local"] as? [String: Any]
        else {
            return nil
        }
        let local:Local? = Local(json:localJSON)
        self.local = local
    }
}

struct PrecipitationXX {
    /**
     * date : 2019-07-08
     * max : 0.6152
     * avg : 0.0731
     * min : 0
     */

    var date:String?
    var max:Double?
    var avg:Double?
    var min:Double?
}

extension PrecipitationXX {
    init?(json: [String: Any]) {
        guard let date = json["date"] as? String,
            let max = json["max"] as? Double,
            let avg = json["avg"] as? Double,
            let min = json["min"] as? Double
        else {
            return nil
        }
        self.date = date
        self.max = max
        self.avg = avg
        self.min = min
    }
}

struct TemperatureX {
    /**
     * date : 2019-07-08
     * max : 0.6152
     * avg : 0.0731
     * min : 0
     */

    var date:String?
    var max:Double?
    var avg:Double?
    var min:Double?
}

extension TemperatureX {
    init?(json: [String: Any]) {
        guard let date = json["date"] as? String,
            let max = json["max"] as? Double,
            let avg = json["avg"] as? Double,
            let min = json["min"] as? Double
        else {
            return nil
        }
        self.date = date
        self.max = max
        self.avg = avg
        self.min = min
    }
}

struct Daily{
    var status:String?
    var temperature:[TemperatureX]? = []
    var precipitation:[PrecipitationXX]? = []
}

extension Daily {
    init?(json: [String: Any]) {
        guard let status = json["status"] as? String,
            let temperaturesJSON = json["temperature"] as? [[String: Any]],
            let precipitationsJSON = json["precipitation"] as? [[String: Any]]
        else {
            return nil
        }

        self.status = status
        for temperatureJSON in temperaturesJSON {
            let temperature:TemperatureX? = TemperatureX(json:temperatureJSON)
            self.temperature?.append(temperature!)
        }
        for precipitationJSON in precipitationsJSON {
            let precipitation:PrecipitationXX? = PrecipitationXX(json:precipitationJSON)
            self.precipitation?.append(precipitation!)
        }
    }
}

struct Realtime{
    var status:String?
    var temperature:Double?
    var precipitation:PrecipitationX?
    var wind:Wind?
    var humidity:Double?
    var skycon:String?
}

extension Realtime {
    init?(json: [String: Any]) {
        guard let status = json["status"] as? String,
            let temperature = json["temperature"] as? Double,
            let precipitationJSON = json["precipitation"] as? [String: Any],
            let windJSON = json["wind"] as? [String: Any],
            let humidity = json["humidity"] as? Double,
            let skycon = json["skycon"] as? String
        else {
            return nil
        }
        self.status = status
        self.temperature = temperature
        
        let precipitation:PrecipitationX? = PrecipitationX(json: precipitationJSON)
        self.precipitation = precipitation

        let wind:Wind? = Wind(json: windJSON)
        self.wind = wind
        
        self.humidity = humidity
        self.skycon = skycon
    }
}

struct WeatherResult{
    var realtime:Realtime?
    var daily:Daily?
}

extension WeatherResult {
    init?(json: [String: Any]) {
        guard let realtimeJSON = json["realtime"] as? [String: Any],
              let dailyJSON = json["daily"] as? [String: Any]
        else {
            return nil
        }
        let realtime:Realtime? = Realtime(json: realtimeJSON)
        let daily:Daily? = Daily(json:dailyJSON)
        
        self.realtime = realtime
        self.daily = daily
    }
}

struct Weather{
    var status:String?
    var result:WeatherResult?
}

extension Weather {
    init?(json: [String: Any]) {
        guard let status = json["status"] as? String,
              let resultJSON = json["result"] as? [String: Any]
        else {
            return nil
        }
        self.status = status
        let result:WeatherResult? = WeatherResult(json: resultJSON)
        self.result = result
    }
}
