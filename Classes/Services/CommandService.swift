//
//  MissionService.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 5/26/19.
//  Copyright © 2019 Evgeny Agamirzov. All rights reserved.
//

import os.log

import DJISDK

enum MissionCommandId {
    case upload
    case start
    case pause
    case resume
    case stop

    var title: String {
        switch self {
            case .upload:
                return "upload"
            case .start:
                return "start"
            case .pause:
                return "pause"
            case .resume:
                return "resume"
            case .stop:
                return "stop"
        }
    }
}

struct MissionParameters {
    var flightSpeed: Float = 10
    var shootDistance: Float = 10
    var altitude: Float = 20
    var turnRadius: Float = 2
}

class CommandService : BaseService {
    // Stored properties
    var currentWaypointIndex: Int?
    var totalWaypoint: UInt?
    var missionParameters = MissionParameters()

    // Notifyer properties
    var logConsole: ((_ message: String, _ type: OSLogType) -> Void)?
    var commandResponded: ((_ id: MissionCommandId, _ success: Bool) -> Void)?
    var missionStarted: (() -> Void)?
    var missionFinished: ((_ success: Bool) -> Void)?
}

// Public methods
extension CommandService {
    func registerListeners() {
        let camera = fetchCamera()
        camera?.delegate = self
        
        Environment.connectionService.listeners.append({ model in
            if model != nil {
                super.start()
                self.subscribeToMissionEvents()
            } else {
                super.stop()
                self.unsubscribeFromMissionEvents()
            }
        })
    }

    func setMissionCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> Bool {
        let missionOperator = DJISDKManager.missionControl()?.waypointMissionOperator()
        let error = missionOperator?.load(waypointMissionFromCoordinates(coordinates))
        if error != nil {
            logConsole?("Mission load error: \(error!.localizedDescription)", .error)
            return false
        } else {
            return true
        }
    }

    func executeMissionCommand(_ id: MissionCommandId) {
        //print ("1")
        if !self.isActive {
            self.logConsole?("Failed to execute \(id.title) command. Aircraft not connected.", .error)
            return
        }
        //print ("2")
        let missionOperator = DJISDKManager.missionControl()?.waypointMissionOperator()
        let callback = { (error: Error?) in
            let success = error == nil
            self.commandResponded?(id, success)
            if success {
                let message = "Mission \(id.title) succeeded"
                self.logConsole?(message, .debug)
            } else {
                let message = "Mission \(id.title) error: \(error!.localizedDescription)"
                self.logConsole?(message, .error)
            }
        }
        //print ("3")
        switch id {
            case .upload:
                missionOperator?.uploadMission(completion: callback)
            case .start:
                missionOperator?.startMission(completion: callback)
            case .pause:
                missionOperator?.pauseMission(completion: callback)
            case .resume:
                missionOperator?.resumeMission(completion: callback)
            case .stop:
                missionOperator?.stopMission(completion: callback)
        }
    }
}

extension CommandService {
    fileprivate func fetchCamera() -> DJICamera? {
        guard let product = DJISDKManager.product() else {
            return nil
        }
        
        if product is DJIAircraft || product is DJIHandheld {
            return product.camera
        }
        return nil
    }
}

extension CommandService: DJICameraDelegate{
    func camera(_ camera: DJICamera, didGenerateNewMediaFile newMedia: DJIMediaFile) {
        if (newMedia.mediaType == DJIMediaType.JPEG){
            TaskUtil.addMediaFile(newMedia)
        }
    }
}

// Private methods
extension CommandService {
    
    /**
     * 开始航线任务定时拍照
     * 每2s拍一张
     */
    func startShootPhoto() {
        if (self.fetchCamera() == nil) {
            //setResultToToast(String.format(getResources().getString(R.string.Start_SP_Failed), getResources().getString(R.string.camera_disconnected)));
            print ("相机实例为空.")
            return
        }
        
        self.fetchCamera()?.setShootPhotoMode(.interval, withCompletion: { (error: Error?) in
            if error == nil {
                self.fetchCamera()?.startShootPhoto(completion: { (error: Error?) in
                    if error == nil {
                        print ("启动拍照成功.")
                    }else{
                        print ("启动拍照失败. \(error!.localizedDescription)")
                    }
                })
            } else {
                print ("设置定时拍照模式失败. \(error!.localizedDescription)")
            }
        })
    }

    /**
     * 结束航线任务定时拍照
     */
    func stopShootPhoto() {
        if (self.fetchCamera() == nil) {
            //setResultToToast(String.format(getResources().getString(R.string.Start_SP_Failed), getResources().getString(R.string.camera_disconnected)));
            print ("相机实例为空.")
            return;
        }
        self.fetchCamera()?.stopShootPhoto(completion: { (error: Error?) in
            if error == nil {
                print ("停止拍照成功.")
            } else {
                print ("停止拍照失败. \(error!.localizedDescription)")
            }
            //将拍照模式切换回单张拍照模式
            self.setCameraShootPhotoMode()
        })
    }
    
    func setCameraShootPhotoMode() {
        if (self.fetchCamera() == nil) {
            //setResultToToast(String.format(getResources().getString(R.string.Start_SP_Failed), getResources().getString(R.string.camera_disconnected)));
            print ("相机实例为空.")
            return;
        }
        
        self.fetchCamera()?.setShootPhotoMode(.single, withCompletion: { (error: Error?) in
            if error == nil {
                print ("设置单张拍照模式成功.")
            } else {
                print ("设置单张拍照模式失败. \(error!.localizedDescription)")
            }
        })
    }
    
    func missionStartPrepare(){
        
        let  now =  Date ()
        let  dformatter =  DateFormatter ()
        dformatter.dateFormat =  "yyyyMMddHHmmss"
        let formatedDate = dformatter.string(from: now)
        TaskUtil.taskCode = "ID"+formatedDate
        //当前时间的时间戳
        let  timeInterval: TimeInterval  = now.timeIntervalSince1970
        let  timeStamp =  Int (timeInterval)
        
        if (TaskUtil.startTime == nil){//说明是没有从续航点开始
            TaskUtil.startTime = timeStamp
        }

        /*
        TaskLab tl = TaskLab.get(ApplicationFactory.getInstance().getBaseApplication());
        Log.d("missionStartPrepare", "missionStartPrepare 2.");

        Weather weather = new Weather();
        WeatherInfo wi = areaUtils.getWeatherInfo();
        if(null!=wi){
            weather.humidity = areaUtils.getWeatherInfo().humidity;
            weather.precipitation = areaUtils.getWeatherInfo().precipitation;
            weather.temperature = areaUtils.getWeatherInfo().temperature;
            weather.temperatureSection = areaUtils.getWeatherInfo().temperatureSection;
            weather.weatherType = areaUtils.getWeatherInfo().weatherType;
            weather.wind = areaUtils.getWeatherInfo().wind;
        }

        Log.d("missionStartPrepare", "missionStartPrepare 3.");

        FlyLineLab fll = FlyLineLab.get(ApplicationFactory.getInstance().getBaseApplication());
        FlyLine fl = fll.getFlyLineByCode(areaUtils.getAreaID());
        FlyLineDetail fld = new FlyLineDetail();
        fld.lat = areaUtils.getStartPoint().latitude;
        fld.lng = areaUtils.getStartPoint().longitude;
        if (null!=fl){
            fld.address = fl.getAddress();
        }

        fld.boundaryId = areaUtils.getAreaID();
        SharedPreferenceUtils sp = new SharedPreferenceUtils(this.getApplicationContext());
        fld.userId = sp.getSaveStringData(Constants.KEY_USERID, "");
        Log.d("missionStartPrepare", "missionStartPrepare 4.");

        TaskBase tb = new TaskBase();
        tb.setCode(task_code);
        tb.setCount(0);
        if(null!=customerInfo){
            tb.setSurveyType(customerInfo.getSurveyType());
            tb.setSurveyContent(customerInfo.getSurveyContent());
        }

        tb.setWeather(weather);
        tb.setFlyLine(fld);
        tb.setMonitorTime(timeStamp);
        tb.setStartTime(timeStamp);
        Log.d("missionStartPrepare", "missionStartPrepare 5.");

        cn.com.mcfly.android.birdeye.bean.TaskLocal t = new cn.com.mcfly.android.birdeye.bean.TaskLocal();
        t.setCode(task_code);
        t.setStatus(0);
        t.setPreviewStatus(0);
        t.setOriginStatus(0);
        t.setSvrTaskId(-1);
        t.setJson(new Gson().toJson(tb));
        tl.addTask(t);
        Log.d("missionStartPrepare", "missionStartPrepare 6.");*/
    }
    
    func missionUpdate(index:Int, total:Int){
        //if (areaUtils != null) {
        //    areaUtils.setTargetWaypointIndex(index, total);
        //    areaUtils.setFinishTargetWaypointIndex(index, total);
        //}
    }
    
    private func subscribeToMissionEvents() {
        let missionOperator = DJISDKManager.missionControl()?.waypointMissionOperator()
        missionOperator?.addListener(toUploadEvent: self, with: DispatchQueue.main, andBlock: { (event: DJIWaypointMissionUploadEvent) in
            if event.error != nil {
                self.logConsole?("Mission upload error: \(event.error!.localizedDescription)", .error)
            }else if event.currentState == .readyToExecute {
                //self.totalWaypoint = event.progress?.totalWaypointCount
            }
        })
        missionOperator?.addListener(toStarted: self, with: DispatchQueue.main, andBlock: {
            self.logConsole?("Mission started successfully", .debug)
            self.missionStarted?()
            //self.startShootPhoto()
        })
        missionOperator?.addListener(toFinished: self, with: DispatchQueue.main, andBlock: { (error: Error?) in
            if error != nil {
                self.logConsole?("Mission finished with error: \(error!.localizedDescription)", .error)
                self.missionFinished?(false)
            } else {
                self.logConsole?("Mission finished successfully", .debug)
                //self.stopShootPhoto()
                self.missionFinished?(true)
            }
        })
        missionOperator?.addListener(toExecutionEvent: self, with: DispatchQueue.main, andBlock: { (event: DJIWaypointMissionExecutionEvent) in
            if event.error != nil {
                self.logConsole?("Mission execution listener error: \(event.error!.localizedDescription)", .error)
            } else if let progress = event.progress {
                if self.currentWaypointIndex == nil || self.currentWaypointIndex != progress.targetWaypointIndex {
                    self.currentWaypointIndex = progress.targetWaypointIndex
                    if self.currentWaypointIndex != nil {
                        self.logConsole?("Heading to waypoint: \(self.currentWaypointIndex!)", .debug)
                    }
                }
                
                // 航点进度逻辑
                let status:Bool = progress.isWaypointReached
                let index:Int = progress.targetWaypointIndex
                if let total:UInt = self.totalWaypoint{
                    
                    let s:DJIWaypointMissionExecuteState = progress.execState
                    if status && s == .beginAction{ //每个航点开始动作，输出信息
                        print ("curStatus index:\(index) total:\(total)")
                    }
                    
                    if (index == 0){ //第一个航点
                        if (status && s == .beginAction) { //摄像头低头前把必要的信息入库保存
                            print ("第一个航点动作开始前.")
                            //setResultToToast(String.format(getResources().getString(R.string.Total_Count), total));
                            self.missionStartPrepare()
                        }
                        if (status && s == .finishedAction) { //摄像头低头后开始拍照
                            print ("第一个航点动作完成后.")
                            //setResultToToast("开始结束，启动拍照");
                            //if (MissionConfig.getInstance().isCameraContorl()) {
                            self.startShootPhoto()
                            //}
                        }
                    }
                    
                    //更新每个航点信息
                    if (s == .finishedAction){
                        //missionUpdate(index, total)
                    }

                    if (index == (total - 1)) { //最后一个航点
                        if (status && s == .beginAction) { //摄像头抬头前停止拍照
                            print("任务结束，停止拍照");
                            //if (MissionConfig.getInstance().isCameraContorl()) {
                            self.stopShootPhoto()
                            //}
                        }
                        if (status && s == .finishedAction) { //相机抬头后记录时间
                            print("任务结束，停止拍照动作完成");
                            //missionStopPrepare()
                        }
                    }
                }
                // 结束
            }
        })
    }

    private func unsubscribeFromMissionEvents() {
        let missionOperator = DJISDKManager.missionControl()?.waypointMissionOperator()
        missionOperator?.removeAllListeners()
    }

    private func waypointMissionFromCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> DJIWaypointMission {
        let mission = DJIMutableWaypointMission()
        mission.maxFlightSpeed = 15
        mission.autoFlightSpeed = missionParameters.flightSpeed
        mission.finishedAction = .goHome
        mission.headingMode = .auto
        mission.flightPathMode = .normal
        //mission.rotateGimbalPitch = true
        mission.exitMissionOnRCSignalLost = true
        mission.gotoFirstWaypointMode = .safely
        mission.repeatTimes = 1
        var index:Int = 0
        for coordinate in coordinates {
            let waypoint = DJIWaypoint(coordinate: coordinate)
            waypoint.altitude = missionParameters.altitude
            //waypoint.actionRepeatTimes = 1
            //waypoint.actionTimeoutInSeconds = 60
            waypoint.turnMode = .clockwise
            if index == 0{
                waypoint.add(DJIWaypointAction(actionType: .rotateGimbalPitch, param: -90))
            }
            if index == coordinates.count - 1{
                waypoint.add(DJIWaypointAction(actionType: .rotateGimbalPitch, param: 0))
            }
            index += 1
            //
            waypoint.shootPhotoDistanceInterval = missionParameters.shootDistance
            waypoint.cornerRadiusInMeters = missionParameters.turnRadius
            mission.add(waypoint)
        }
        self.totalWaypoint = UInt(coordinates.count)
        return DJIWaypointMission(mission: mission)
    }
}
