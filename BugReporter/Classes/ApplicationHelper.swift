//
//  ApplicationHelper.swift
//  Pods
//
//  Created by Kimi on 28/4/17.
//
//

import UIKit

class ApplicationHelper: NSObject {

    class func name() -> String? {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String
    }
    
    class func displayName() -> String? {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    }
    
    class func appVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    class func build() -> String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
}
