//
//  taskUtil.swift
//  Bird14
//
//  Created by yu xiaohe on 2020/11/2.
//

import Foundation
import DJISDK

class TaskUtil {
    static var startTime:Int?
    static var endTime:Int?
    
    static var taskCode:String?
    static var boundaryId:String?
    
    static var mediaFileList:[DJIMediaFile] = []
    
    static func addMediaFile(_ mediaFile:DJIMediaFile ) {
        mediaFileList.append(mediaFile);
    }
}
