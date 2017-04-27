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
        
        return true
    }

}

