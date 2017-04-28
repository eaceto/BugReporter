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
        
        _ = BugReporter.setup(with: launchOptions, delegate: self)    // call as soon as possible
                       .report(using: .email)   // can set it or change it later
                       .debug(false)  // enable or disable debug at any time
        
        return true
    }

    
    //MARK: Bug Report delegate
    func userDidStartAReport(_ report: Report) {
        debugPrint("userDidStartAReport: \(report)")
    }
    
    func userDidCancelAReport(_ report: Report) {
        debugPrint("userDidCancelAReport: \(report)")
    }
    
    func userDidSendAReport(_ report : Report, using mode: ReportingMode) {
        debugPrint("userDidSendAReport: \(report) using: \(mode.rawValue)")
    }
    
    func userDidSaveAReport(_ report: Report, using mode: ReportingMode) {
        debugPrint("userDidSaveAReport: \(report) using: \(mode.rawValue)")
    }
    
    func appendMoreImages(to report: Report) -> [UIImage]? {
        return nil
    }
    
}

