//
//  LibHelper.swift
//  Pods
//
//  Created by Kimi on 28/4/17.
//
//

import UIKit

internal class LibHelper: NSObject {

    static let LIB_VERSION = "0.1.7"
    
    class func libBundle() -> Bundle? {
        let podBundle = Bundle(for: LibHelper.self)
        if let url = podBundle.url(forResource: "BugReporter", withExtension: "bundle") {
            return Bundle(url: url)
        }
        return nil
    }
}
