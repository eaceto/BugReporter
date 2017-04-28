//
//  ShareViaPDFHelper.swift
//  Pods
//
//  Created by Kimi on 4/28/17.
//
//

import UIKit

class ShareViaPDFHelper: NSObject {

    fileprivate static let PAPER_A4_WIDTH = 595.2  // A4 72dpi
    fileprivate static let PAPER_A4_HEIGHT = 841.8  // A4 72dpi
    
    class func share(report : Report, using topVC : UIViewController) -> Bool {
        guard let reportData = report.createPDF() else {
            if BugReporter.debugEnabled {
                debugPrint("Fail to create PDF report")
            }
            return false
        }
        
        let path = NSTemporaryDirectory().appending(report.fileName(extension: "pdf"))
        guard FileManager.default.createFile(atPath: path, contents: reportData, attributes: nil) else {
            if BugReporter.debugEnabled {
                debugPrint("Fail to create report file")
            }
            return false
        }
        
        var files : [Any] = [URL(fileURLWithPath: path)]
        for image in report.images {
            if let imageData = UIImageJPEGRepresentation(image, 0.9) {
                files.append(imageData)
            }
        }
        
        let activityVC = UIActivityViewController(activityItems: files , applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = topVC.view
        activityVC.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            try? FileManager.default.removeItem(atPath: path)
            BugReporter.shared.didFinishedProcessing(report, status: .cancelled)
        }
        
        topVC.present(activityVC, animated: true, completion: nil)
        
        return true
    }
    
    class func render(html : String) -> Data? {
        let fmt = UIMarkupTextPrintFormatter(markupText: html)
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        let page = CGRect(x: 0, y: 0, width: PAPER_A4_WIDTH, height: PAPER_A4_HEIGHT)
        let printable = page.insetBy(dx: 0, dy: 0)
        
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
        
        for i in 1...render.numberOfPages {
            
            UIGraphicsBeginPDFPage()
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext()
        
        return pdfData as Data
    }
    
}
