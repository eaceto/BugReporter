//
//  Report.swift
//  Pods
//
//  Created by Kimi on 27/4/17.
//
//

import UIKit
import SwiftyJSON

public class Report: NSObject {
    
    internal var launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    internal var applicationId: String?
    internal var notification: Notification?
    internal let bundleId = Bundle.main.bundleIdentifier
    internal var images = [UIImage]()
    internal var currentViewController : UIViewController?
    internal var created : Date
    
    private override init() {
        self.created = Date()
        super.init()
    }
    
    internal init (from notification: Notification, launchOptions : [UIApplicationLaunchOptionsKey:Any]?, applicationId: String) {
        self.created = Date()
        self.notification = notification
        self.launchOptions = launchOptions
        self.applicationId = applicationId
        
        super.init()
    }
    
    internal func json() -> JSON {
        var j = JSON(["applicationId" : self.applicationId ?? "",
                      "isEmulator" : BRJBDetect.isEmulator(),
                      "isJailBroken" : BRJBDetect.isJailbroken(),
                      "creationTimestamp" : UInt64(self.created.timeIntervalSince1970),
                      "creationDate" : self.created.description])
    
        j["application"] = applicationDescription()
        j["device"] = DeviceHelper.deviceDescription()
        
        if BRJBDetect.isJailbroken() {
            j["jailbreakMethod"].string = BRJBDetect.jailbrakeMethod()
        }
        
        if let vc = currentViewController {
            var vcInfo = [String:String]()
            if let title = vc.title {
                vcInfo["title"] = title
            }
            if let nib = vc.nibName {
                vcInfo["nibName"] = nib
            }
            vcInfo["class"] = String(describing: type(of: vc))

            j["viewController"].dictionaryObject = vcInfo
        }
        
        j["attachedImages"].int = images.count
        
        return j
    }
    
    internal func applicationDescription() -> JSON {
        var j = JSON(["bundleId" : self.bundleId ?? "",])
        
        if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            j["name"].string = name
        }
        
        if let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            j["displayName"].string = name
        }
        
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            j["version"].string = appVersion
        }
        
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            j["build"].string = build
        }
                
        return j
    }
    
    internal func add(image : UIImage) {
        self.images.append(image)
    }
    
    internal func from(viewController : UIViewController) {
        self.currentViewController = viewController
    }
}
