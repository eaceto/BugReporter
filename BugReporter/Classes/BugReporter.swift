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

internal enum ReportStatus : String {
    case sent
    case draft
    case cancelled
}

public enum ReportingMode : String {
    case disabled
    case email
    case share
    case userSelect
}

public protocol BugReporterDelegate {
    
    // Report life cycle
    func userDidStartAReport(_ report : Report)
    func userDidCancelAReport(_ report : Report)
    func userDidSendAReport(_ report : Report)
    func userDidSaveAReport(_ report : Report)
    
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
    fileprivate var lifeCycleDelegate : BugReporterDelegate?
    fileprivate var currentReport : Report?
    
    //MARK: Debug Variable
    internal static var debugEnabled = false
    
    //MARK: Init
    private override init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        self.applicationId = ""
        self.launchOptions = nil
        self.reportingMode = .email
        
        super.init()
        self.initScreenshotObserver()
    }
    
    public class func setup(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> BugReporter {
        BugReporter.shared.launchOptions = launchOptions
        
        if let path = Bundle.main.path(forResource: "BugReporterSettings", ofType: "plist") {
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                if let appId = dic["applicationId"] as? String {
                    BugReporter.shared.applicationId = appId
                }
            }
        }
        
        return BugReporter.shared
    }
    
    @available(*, deprecated: 0.0.1, renamed: "setup(with:)")
    public class func setup(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?, delegate reportDelegate : BugReporterDelegate?) -> BugReporter {
        fatalError("use setupe(with:) insted")
    }

    public func delegate(_ delegate : BugReporterDelegate) -> BugReporter {
        BugReporter.shared.lifeCycleDelegate = delegate
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
        BugReporter.debugEnabled = enabled
        return BugReporter.shared
    }
    
    private func processReport(from notification : Notification) {
        if BugReporter.debugEnabled {
            debugPrint("didDectectAnScreenshotTaken: \(notification)")
            debugPrint("reporting mode: \(self.reportingMode.rawValue)")
        }
        
        guard currentReport == nil else {
            if BugReporter.debugEnabled {
                debugPrint("Sorry, Bug Report cannot handle another bug report (yet) while there is a report in progress.")
            }
            return
        }
        
        guard lifeCycleDelegate != nil else {
            if BugReporter.debugEnabled {
                debugPrint("Bug Report delegate is not set. report will not be handled")
            }
            return
        }
        
        guard let topVC = topViewController() else {
            if BugReporter.debugEnabled {
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
            
            if let delegate = self.lifeCycleDelegate {
                
                delegate.userDidStartAReport(report)
                
                if let otherImages = delegate.appendMoreImages(to: report) {
                    for image in otherImages {
                        report.add(image: image)
                    }
                }
            }
            
            switch self.reportingMode {
            case .email:
                self.sendReportUsingEmail(report, from: topVC)
                return
                
            case .share:
                self.sendReportUsingActivityController(report, from: topVC)
                break
                
            case .userSelect:
                let title = "Send report"
                let message = "How would like to send this report?"
                let cancel = "Don't send it"
                let share = "Using another app"
                let email = "Via email"
                
                let actionSheet = UIAlertController.init(title: title, message: message, preferredStyle: .actionSheet)
                actionSheet.popoverPresentationController?.sourceView = topVC.view
                
                actionSheet.addAction(UIAlertAction.init(title: email, style: .default, handler: { action in
                    self.sendReportUsingEmail(report, from: topVC)
                }))
                
                actionSheet.addAction(UIAlertAction.init(title: share, style: .default, handler: { action in
                    self.sendReportUsingActivityController(report, from: topVC)
                }))
                
                actionSheet.addAction(UIAlertAction.init(title: cancel, style: .destructive, handler: { action in
                    self.didFinishedProcessing(report, status: .cancelled)
                }))
                
                topVC.present(actionSheet, animated: true, completion: nil)
                return
                
            case .disabled:
                if BugReporter.debugEnabled {
                    debugPrint("Reporting is disabled")
                }
                break
            }
            
            self.didFinishedProcessing(report, status: .cancelled)
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
            let ext = "jpeg"
            if let imageData = UIImageJPEGRepresentation(image, 0.9) {
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
        if let report = self.currentReport {
            switch result {
            case .sent:
                self.didFinishedProcessing(report, status: .sent)
                break
            case .saved:
                self.didFinishedProcessing(report, status: .draft)
                break
            default:
                self.didFinishedProcessing(report, status: .cancelled)
                break
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func sendReportUsingEmail(_ report : Report, from vc : UIViewController) {
        if !MFMailComposeViewController.canSendMail() {
            if BugReporter.debugEnabled {
                debugPrint("Mail services are not available")
            }
            return
        }
        
        if BugReporter.debugEnabled {
            debugPrint("Reporting information\n====================\n\(report.json())\n====================")
        }
        
        self.emailReport(report, from: vc)
    }
    
    fileprivate func sendReportUsingActivityController(_ report : Report, from vc : UIViewController) {
        if !ShareViaPDFHelper.share(report: report, using: vc) {
            if BugReporter.debugEnabled {
                debugPrint("Fail to create HTML report")
            }
        }
    }
    
    internal func didFinishedProcessing(_ report : Report, status : ReportStatus) {
        if let d = lifeCycleDelegate {
            switch status {
            case .cancelled:
                if BugReporter.debugEnabled {
                    debugPrint("Report not sent neither saved")
                }
                d.userDidCancelAReport(report)
                break
            case .sent:
                if BugReporter.debugEnabled {
                    debugPrint("Report sent")
                }
                d.userDidSendAReport(report)
                break
            case .draft:
                if BugReporter.debugEnabled {
                    debugPrint("Report saved")
                }
                d.userDidSaveAReport(report)
                break
            }
        }
        self.currentReport = nil
    }
}
