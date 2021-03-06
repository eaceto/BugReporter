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
    
    class func systemFileSystemSize() -> Int64? {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let totalSize = (systemAttributes[.systemSize] as? NSNumber)?.int64Value else {
                return nil
        }
        
        return totalSize
    }
    
    class func systemFileSystemFreeSize() -> Int64? {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let freeSize = (systemAttributes[.systemFreeSize] as? NSNumber)?.int64Value else {
                return nil
        }
        
        return freeSize
    }
    
    class func deviceDescription() -> JSON {
        var j = JSON(["model" : model(),
                      "multitasking" : multitaskingSupported(),
                      "systemVersion" :  systemVersion(),
                      "systemName" :  systemName()])
        
        j["battery"].dictionaryObject = ["level" : batteryLevel(), "state" : batteryState()]
        
        let fsSize = systemFileSystemSize()
        let fsFreeSize = systemFileSystemFreeSize()
        
        if fsSize != nil || fsFreeSize != nil {
            var fs = [String:String]()
            if let s = fsSize {
                fs["capacity"] = "\(Float(s) / 1024.0 / 1024.0) MB"
            }
            if let f = fsFreeSize {
                fs["free"] = "\(Float(f) / 1024.0 / 1024.0) MB"
            }
            j["fileSystem"].dictionaryObject = fs
        }
        
        if let memory = RAMHelper.stats() as? [String : Any] {
            j["memory"].dictionaryObject = memory
        }
        
        return j
    }
}
