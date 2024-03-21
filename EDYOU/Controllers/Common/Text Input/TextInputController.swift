//
//  TextInputController.swift
//  EDYOU
//
//  Created by  Mac on 15/09/2021.
//

import UIKit

class TextInputController: BaseController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var viewTextFieldBg: UIView!
    
    @IBOutlet weak var cstTextViewBottom: NSLayoutConstraint!
    
    private var strTitle = ""
    private var strText = ""
    private var multiline = false
    private var required = false
    private var completion: ((_ text: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = strTitle
        
        
        if multiline {
            textField.isHidden = true
            textView.isHidden = false
            textView.text = strText
            placeholderLabel.isHidden = (textView.text?.count ?? 0) > 0
        } else {
            textField.isHidden = false
            textView.isHidden = true
            textField.text = strText
            placeholderLabel.isHidden = (textField.text?.count ?? 0) > 0
        }
        
    }
    
    override func keyboardWillChangeFrame(to frame: CGRect) {
        if frame.height > 0 {
            cstTextViewBottom.constant = frame.height - Application.shared.safeAreaInsets.bottom
        } else {
            cstTextViewBottom.constant = 0
        }
    }
    
    init(title: String, currentText: String, required: Bool = false, multiline: Bool, completion: @escaping (_ text: String) -> Void) {
        super.init(nibName: TextInputController.name, bundle: nil)
        
        self.strTitle = title
        self.strText = currentText
        self.required = required
        self.multiline = multiline
        self.completion = completion
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapDoneButton(_ sender: UIButton) {
        if multiline {
            let text = (textView.text ?? "").trimmed
            if text.count == 0 && required {
                textView.borderColor = .red
                textView.borderWidth = 1
                textView.cornerRadius = 8
                sender.shake()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.textView.borderColor = .clear
                    self.textView.borderWidth = 0
                    self.textView.cornerRadius = 0
                }
                
            } else {
                completion?(text)
                self.dismiss(animated: true, completion: nil)
            }
            
        } else {
            let text = (textField.text ?? "").trimmed
            if text.count == 0 && required {
                viewTextFieldBg.borderColor = .red
                viewTextFieldBg.borderWidth = 1
                viewTextFieldBg.cornerRadius = 8
                sender.shake()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.viewTextFieldBg.borderColor = .clear
                    self.viewTextFieldBg.borderWidth = 0
                    self.viewTextFieldBg.cornerRadius = 0
                }
                
            } else {
                completion?(text)
                self.dismiss(animated: true, completion: nil)
            }            
        }
    }
    
    
}

extension TextInputController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = textView.text.count > 0
    }
}

extension TextInputController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let expectedText = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        placeholderLabel.isHidden = expectedText.count > 0
        
        return true
    }
}
