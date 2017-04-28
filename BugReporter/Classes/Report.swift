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
    
        j["bugReporter"].dictionaryObject = ["version" : LibHelper.LIB_VERSION]
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
        
        if let name = ApplicationHelper.name() {
            j["name"].string = name
        }
        
        if let displayName = ApplicationHelper.displayName() {
            j["displayName"].string = displayName
        }
        
        if let appVersion = ApplicationHelper.appVersion() {
            j["version"].string = appVersion
        }
        
        if let build = ApplicationHelper.build() {
            j["build"].string = build
        }
                
        return j
    }
    
    //FIXME implement render protocol and different kinds of render
    internal func createPDF() -> Data? {
        guard let bundle = LibHelper.libBundle() else {
            return nil
        }
        
        do {
            // Load the invoice HTML template code into a String variable.
            var html = try String(contentsOfFile: bundle.path(forResource: "PDFReportTemplate", ofType: "html")!)

            let jsonReport = String(describing: json()).htmlEscape()
                .replacingOccurrences(of: "\n", with: "</br>")
                .replacingOccurrences(of: " ", with: "&nbsp;")
            
            html = html.replacingOccurrences(of: "#JSON_REPORT#", with: jsonReport)
            
            if let name = ApplicationHelper.name() {
                html = html.replacingOccurrences(of: "#APP_NAME#", with: name.htmlEscape())
            } else {
                html = html.replacingOccurrences(of: "#APP_NAME#", with: "undefined")
            }
            
            guard let pdfData = ShareViaPDFHelper.render(html: html) else {
                if BugReporter.debugEnabled {
                    debugPrint("Cannot create PDF file")
                }
                return nil
            }
            
            return pdfData
        } catch {
            if BugReporter.debugEnabled {
                debugPrint("Exception creating HTML report")
            }

        }
        
        return nil
    }
    
    internal func add(image : UIImage) {
        self.images.append(image)
    }
    
    internal func from(viewController : UIViewController) {
        self.currentViewController = viewController
    }
    
    internal func writeToDisk() -> Bool {
        let path = filePath()
        do{
            let json = String(describing: self.json())
            try json.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            return true
        }catch{
            return false
        }
    }
    
    internal func deleteFromDisk() -> Bool {
        let path = filePath()
        do {
            try FileManager.default.removeItem(atPath: path)
            return true
        }
        catch {}
        return false
    }
    
    internal func fileData() -> Data? {
        let path = filePath()
        
        let file: FileHandle? = FileHandle(forReadingAtPath: path)
        
        if file != nil {
            let data = file?.readDataToEndOfFile()
            file?.closeFile()
            return data
        }
        return nil
    }
    
    internal func filePath() -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        return documentsPath.appendingPathComponent(fileName(extension: "json"))
    }
    
    internal func fileName(extension ext : String) -> String {
        return "bugreport_\(UInt64(created.timeIntervalSince1970)).\(ext)"
    }
}
