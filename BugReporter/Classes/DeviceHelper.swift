//
//  DeviceHelper.swift
//  Pods
//
//  Created by Kimi on 27/4/17.
//
//

import UIKit
import SwiftyJSON

class DeviceHelper: NSObject {
    class func batteryLevel() -> Float {
        return UIDevice.current.batteryLevel
    }
    
    class func batteryState() -> String {
        switch UIDevice.current.batteryState {
        case .charging:
            return "charging"
        case .full:
            return "full"
        case .unplugged:
            return "unplugged"
        case .unknown:
            return "unknown"
        }
    }
    
    class func multitaskingSupported() -> Bool {
        return UIDevice.current.isMultitaskingSupported
    }
    
    class func model() -> String {
        return UIDevice.current.model
    }
    
    class func systemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    class func systemName() -> String {
        return UIDevice.current.systemName
    }
    
    class func deviceDescription() -> JSON {
        var j = JSON(["model" : model(),
                      "multitasking" : multitaskingSupported(),
                      "systemVersion" :  systemVersion(),
                      "systemName" :  systemName()])
        
        j["battery"].dictionaryObject = ["level" : batteryLevel(), "state" : batteryState()]
        
        return j
    }
    
}
