//
//  PinCodeTextField.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit

@IBDesignable
class PinCodeTextField: UIView {
    
    var view: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var txtPin1: MyTextField!
    @IBOutlet weak var txtPin2: MyTextField!
    @IBOutlet weak var txtPin3: MyTextField!
    @IBOutlet weak var txtPin4: MyTextField!
    
//    private var textFieldHeight: CGFloat = 60
//    @IBInspectable var boxSize: CGFloat {
//        set {
//            textFieldHeight = newValue
//            stackView.spacing = (view.frame.width - (textFieldHeight * 5)) / 4
//            view?.layoutIfNeeded()
//
//        }
//        get {
//            return textFieldHeight
//        }
//    }
    
    var text: String {
        return "\(txtPin1.text ?? "")\(txtPin2.text ?? "")\(txtPin3.text ?? "")\(txtPin4.text ?? "")"
    }
    var hasValidText: Bool {
        return (txtPin1.text ?? "") != "" && (txtPin2.text ?? "") != "" && (txtPin3.text ?? "") != "" && (txtPin4.text ?? "") != ""
    }
    
    func showErrorForEmptyFields() {
        resetError()
        
        [txtPin1, txtPin2, txtPin3, txtPin4].forEach { (textField) in
            if (textField?.text ?? "") == "" {
                textField?.borderColor = UIColor.red
                textField?.borderWidth = 1
            }
        }
        
        
    }
    
    func resetError() {
        [txtPin1, txtPin2, txtPin3, txtPin4].forEach { (textField) in
            textField?.borderColor = UIColor.clear
            textField?.borderWidth = 0
        }
    }
    
    // MARK: - View Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    func xibSetup() {
        backgroundColor = .clear
        view = loadViewFromNib() 
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
        
        txtPin1.customDelegate = self
        txtPin2.customDelegate = self
        txtPin3.customDelegate = self
        txtPin4.customDelegate = self
        
        view.layoutIfNeeded()
        
//        stackView.spacing = (view.frame.width - (textFieldHeight)) / 4
        
        
    }
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }
    
    @IBAction func textDidChange(_ sender: UITextField) {
        if sender == txtPin1 {
            if (txtPin1.text?.count ?? 0) > 0 {
                txtPin2.becomeFirstResponder()
            }
        } else if sender == txtPin2 {
            if (txtPin2.text?.count ?? 0) > 0 {
                txtPin3.becomeFirstResponder()
            }
        } else if sender == txtPin3 {
            if (txtPin3.text?.count ?? 0) > 0 {
                txtPin4.becomeFirstResponder()
            }
        }
    }
}

extension PinCodeTextField: UITextFieldDelegate, MyTextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.borderColor = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
        if (textField.text?.count ?? 0) > 0 && string.count > 0 {
            return false
        }
        return true
    }
    
    func didPressBackSpaceOnEmptyField(for textField: MyTextField) {
        if textField == txtPin4 {
            txtPin3.deleteBackward()
            txtPin3.becomeFirstResponder()
        } else if textField == txtPin3 {
            txtPin2.deleteBackward()
            txtPin2.becomeFirstResponder()
        } else if textField == txtPin2 {
            txtPin1.deleteBackward()
            txtPin1.becomeFirstResponder()
        }
    }
    
}


protocol MyTextFieldDelegate {
    func didPressBackSpaceOnEmptyField(for textField: MyTextField)
}

class MyTextField: UITextField {
    var customDelegate: MyTextFieldDelegate?
    
    override func deleteBackward() {
        if (self.text?.count ?? 0) > 0 {
            super.deleteBackward()
        } else {
            customDelegate?.didPressBackSpaceOnEmptyField(for: self)
        }
    }
    
}
