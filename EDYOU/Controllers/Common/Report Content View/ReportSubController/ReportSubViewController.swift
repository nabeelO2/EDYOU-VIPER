//
//  ReportSubViewController.swift
//  EDYOU
//
//  Created by Jamil Macbook on 29/12/22.
//

import UIKit
import TransitionButton

class ReportSubViewController: BaseController {
    
    let otherMessage = "We don't allow \n\n• Our priority is to provide a safe and supportive environement. We also encourage authentic interations by keeping deceptive content and accounts off our platform."
    
    let genericMessage = "Report this content if it's and ad that is being displayed where is shouldn't be."
    
    @IBOutlet weak var screenTitleLabel: UILabel!
    var screenTitle: String?

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var btnSave: TransitionButton!
    
    var reportObject: ReportContent?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenTitleLabel.text = screenTitle ?? "Spam"
        // Do any additional setup after loading the view.
        setupLabelAttributedText()
    }

    func setupLabelAttributedText() {
        descriptionLabel.attributedText = NSAttributedString(string: getDescriptionLabelMessage(), attributes:[NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14) as Any])
    }

    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func getDescriptionLabelMessage() -> String {
//        print("postid: \(reportObject?.contentID!)")
//        print("contentType: \(reportObject?.contentType!)")
//        print("reportType: \(reportObject?.reportType!)")
        if (reportObject?.reportType == "other_content") {
            return otherMessage
        } else {
           return genericMessage
        }
    }
    
    @IBAction func submitReport(_ sender: UIButton) {
        reportContent()
    }

}

extension ReportSubViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        reportObject?.reportMessage = textView.text ?? "Test message"
    }
}

extension ReportSubViewController {
    
    func reportContent() {
        self.startLoading(title: "")
        reportObject?.reportMessage = textView.text ?? "Test"
        APIManager.reportContentManager.reportContent(reportObject: reportObject!) { response, error in
            self.stopLoading()
            if error == nil {
                //self.navigationController?.popToRootViewController(animated: true)
                self.moveToReportThanksScreen()
            } else {
                self.showErrorWith(message: error?.message.description ?? "")
            }
        }

    }
    
    func moveToReportThanksScreen() {
        let navC =  self.parent?.tabBarController?.navigationController ?? self.navigationController
        let controller = ReportThanksViewController(nibName: "ReportThanksViewController", bundle: nil)
        controller.reportObject = reportObject
        navC?.pushViewController(controller, animated: true)
    }
}
