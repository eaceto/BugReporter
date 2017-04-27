//
//  BugReporter.swift
//  Pods
//
//  Created by Kimi on 27/4/17.
//
//

import UIKit
import MessageUI
import Photos

public protocol BugReporterDelegate {
    
}

public class BugReporter: NSObject, MFMailComposeViewControllerDelegate {
    
    public enum ReportingMode : String {
        case disabled
        case email
    }
    
    //MARK: Shared Instance
    static let shared : BugReporter = {
        let instance = BugReporter()
        return instance
    }()
    
    //MARK: Local Variable
    fileprivate var launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    fileprivate var applicationId: String
    fileprivate var reportingMode: ReportingMode
    fileprivate var delegate : BugReporterDelegate?
    
    //MARK: Debug Variable
    fileprivate var debug = true
    
    //MARK: Init
    private override init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        self.applicationId = ""
        self.launchOptions = nil
        self.reportingMode = .email
        
        super.init()
        self.initScreenshotObserver()
    }
    
    public class func setup(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?, delegate reportDelegate : BugReporterDelegate?) -> BugReporter {
        BugReporter.shared.launchOptions = launchOptions
        BugReporter.shared.delegate = reportDelegate
        
        if let path = Bundle.main.path(forResource: "BugReporterSettings", ofType: "plist") {
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                if let appId = dic["applicationId"] as? String {
                    BugReporter.shared.applicationId = appId
                }
            }
        }
        
        return BugReporter.shared
    }
    
    public func report(using mode : ReportingMode) -> BugReporter {
        BugReporter.shared.reportingMode = mode
        return BugReporter.shared
    }
    
    private func initScreenshotObserver() {
        let mainQueue = OperationQueue.main
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationUserDidTakeScreenshot,
                                               object: nil,
                                               queue: mainQueue,
                                               using: { notification in
                                                self.processReport(from: notification)
        })
    }
    
    public func disableDebug() {
        self.debug = false
    }
    
    private func processReport(from notification : Notification) {
        if debug {
            debugPrint("didDectectAnScreenshotTaken: \(notification)")
            debugPrint("repoting mode: \(self.reportingMode.rawValue)")
        }
        
        guard delegate != nil else {
            if debug {
                debugPrint("Bug Report delegate is not set. report will not be handled")
            }
            return
        }
        
        guard let topVC = topViewController() else {
            if self.debug {
                debugPrint("Bug Report did not find a View Controller to present the report")
            }
            return
        }
        
        takeScreenshot(from: topVC, completion: { screenshot in
            
            let report = Report(from: notification, launchOptions: self.launchOptions, applicationId: self.applicationId)
            
            report.from(viewController: topVC)
            
            if let screenshot = screenshot {
                report.add(image: screenshot)
            }
            
            switch self.reportingMode {
            case .email:
                if !MFMailComposeViewController.canSendMail() {
                    if self.debug {
                        debugPrint("Mail services are not available")
                    }
                    return
                }
                
                if self.debug {
                    debugPrint("Reporting information\n====================\n\(report.json())\n====================")
                }
                
                self.emailReport(report, from: topVC)
                
                break
                
            default: break
            }
            
        })
    }
    
    private func appName() -> String {
        if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return name
        }
        return "undefined"
    }
    
    private func emailReport(_ report : Report, from vc : UIViewController) {
        let mail:MFMailComposeViewController = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject("[\(appName())] New issue reported from Bug Reporter")
        mail.setToRecipients(mailRecipients())
        
        let emailBody = "<h1>Bug Report</h1>\n<code>\(String(describing: report.json()).replacingOccurrences(of: "\n", with: "</br>"))</code>"
        
        var idx = 0
        for image in report.images {
            let ext = "png"
            if let imageData = UIImagePNGRepresentation(image) {
                mail.addAttachmentData(imageData, mimeType: MimeType(ext: ext), fileName: "attachment_\(idx).\(ext)")
                idx = idx + 1
            }
        }
        
        mail.setMessageBody(emailBody, isHTML:true)
        vc.present(mail, animated: true, completion:nil)
    }
    
    private func mailRecipients() -> [String] {
        if let path = Bundle.main.path(forResource: "BugReporterSettings", ofType: "plist") {
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                if let emails = dic["reportEMails"] as? [String] {
                    return emails
                }
            }
        }
        return [String]()
    }
    
    private func takeScreenshot(from viewController : UIViewController, completion: @escaping (UIImage?) -> ()) {
        UIGraphicsBeginImageContext(CGSize(width: viewController.view.frame.width, height: viewController.view.frame.height))
        viewController.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        completion(image)
    }
    
    private func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if debug {
            switch result {
            case .sent:
                debugPrint("Report sent")
                break
            case .saved:
                debugPrint("Report saved")
                break
            default:
                debugPrint("Report not sent neither saved")
                break
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
}
