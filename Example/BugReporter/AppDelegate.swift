//
//  AppDelegate.swift
//  BugReporter
//
//  Created by Kimi on 04/27/2017.
//  Copyright (c) 2017 Kimi. All rights reserved.
//

import UIKit
import BugReporter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BugReporterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        _ = BugReporter.setup(with: launchOptions)      // call as soon as possible
                       .delegate(self)                  // set in order to receive events (optional)
                       .report(using: .userSelect)      // let user decide how. You can change this later
                       .debug(false)                    // enable or disable debug at any time
        
        return true
    }

    
    //MARK: Bug Report delegate
    func userDidStartAReport(_ report: Report) {
        debugPrint("userDidStartAReport: \(report)")
    }
    
    func userDidCancelAReport(_ report: Report) {
        debugPrint("userDidCancelAReport: \(report)")
    }
    
    func userDidSendAReport(_ report : Report) {
        debugPrint("userDidSendAReport: \(report) using: \(report.sendMechanism?.rawValue ?? "undefined")")
    }
    
    func userDidSaveAReport(_ report: Report) {
        debugPrint("userDidSaveAReport: \(report) using: \(report.sendMechanism?.rawValue ?? "undefined")")
    }
    
    func appendMoreImages(to report: Report) -> [UIImage]? {
        return nil
    }
    
}

