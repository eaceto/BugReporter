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

public enum ReportingMode : String {
    case disabled
    case email
}

public protocol BugReporterDelegate {
    
    // Report life cycle
    func userDidStartAReport(_ report : Report)
    func userDidCancelAReport(_ report : Report)
    func userDidSendAReport(_ report : Report, using mode: ReportingMode)
    func userDidSaveAReport(_ report : Report, using mode: ReportingMode)
    
    func appendMoreImages(to report: Report) -> [UIImage]?
}

public class BugReporter: NSObject, MFMailComposeViewControllerDelegate {
    
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
    fileprivate var currentReport : Report?
    
    //MARK: Debug Variable
    fileprivate var debugEnabled = false
    
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
    
    public func debug(_ enabled : Bool) -> BugReporter {
        self.debugEnabled = enabled
        return BugReporter.shared
    }
    
    private func processReport(from notification : Notification) {
        if debugEnabled {
            debugPrint("didDectectAnScreenshotTaken: \(notification)")
            debugPrint("reporting mode: \(self.reportingMode.rawValue)")
        }
        
        guard currentReport == nil else {
            if debugEnabled {
                debugPrint("Sorry, Bug Report cannot handle another bug report (yet) while there is a report in progress.")
            }
            return
        }
        
        guard delegate != nil else {
            if debugEnabled {
                debugPrint("Bug Report delegate is not set. report will not be handled")
            }
            return
        }
        
        guard let topVC = topViewController() else {
            if self.debugEnabled {
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
            
            self.currentReport = report
            
            if let delegate = self.delegate {
                
                delegate.userDidStartAReport(report)
                
                if let otherImages = delegate.appendMoreImages(to: report) {
                    for image in otherImages {
                        report.add(image: image)
                    }
                }
            }
            
            switch self.reportingMode {
            case .email:
                if !MFMailComposeViewController.canSendMail() {
                    if self.debugEnabled {
                        debugPrint("Mail services are not available")
                    }
                    return
                }
                
                if self.debugEnabled {
                    debugPrint("Reporting information\n====================\n\(report.json())\n====================")
                }
                
                self.emailReport(report, from: topVC)
                
                return
                
            default: break
            }
            
            self.currentReport = nil
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
        mail.setSubject("[\(appName())] New issue")
        mail.setToRecipients(mailRecipients())
        
        let json = report.json()
        
        let htmlReport = String(describing: json).htmlEscape()
            .replacingOccurrences(of: "\n", with: "</br>")
            .replacingOccurrences(of: " ", with: "&nbsp;")
        
        let emailBody = "<h1>Bug Report</h1>\n" +
            "<h2>Notes</h2>\n" +
            "<p>(insert your notes here)</p>\n" +
            "<h2>Report</h2><code>\(htmlReport)</code>\n\n" +
            "<p>sent with ❤️ from BugReporter</p>"
        
        for (idx, image) in report.images.enumerated() {
            let ext = "png"
            if let imageData = UIImagePNGRepresentation(image) {
                mail.addAttachmentData(imageData, mimeType: MimeType(ext: ext), fileName: "attachment_\(idx).\(ext)")
            }
        }
        
        if report.writeToDisk() {
            if let content = report.fileData() {
                mail.addAttachmentData(content, mimeType: MimeType(ext: "json"), fileName: "bugreport.json")
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
        switch result {
        case .sent:
            if debugEnabled {
                debugPrint("Report sent")
            }
            
            if let d = self.delegate, let report = self.currentReport {
                d.userDidSendAReport(report, using: .email)
            }
            break
        case .saved:
            if debugEnabled {
                debugPrint("Report saved")
            }
            
            if let d = self.delegate, let report = self.currentReport {
                d.userDidSaveAReport(report, using: .email)
            }
            break
        default:
            if debugEnabled {
                debugPrint("Report not sent neither saved")
            }
            
            if let d = self.delegate, let report = self.currentReport {
                d.userDidCancelAReport(report)
            }
            break
        }
        
        currentReport = nil
        
        controller.dismiss(animated: true, completion: nil)
    }
}
