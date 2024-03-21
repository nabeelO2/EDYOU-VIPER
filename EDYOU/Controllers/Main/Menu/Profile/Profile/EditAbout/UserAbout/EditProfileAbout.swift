//
//  EditProfileAbout.swift
//  EDYOU
//
//  Created by Admin on 06/06/2022.
//

import UIKit
import TransitionButton


class EditProfileAbout: BaseController {
    
    @IBOutlet weak var lblCountWords: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var btnSave: TransitionButton!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = user.about
        lblCountWords.text = "\(textView.text.count)/2600 "
        textView.delegate = self
    }
    init(user: User) {
        self.user = user
        super.init(nibName: EditProfileAbout.name, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.user = User.nilUser
        super.init(coder: coder)
    }
    deinit {
        print("[EditProfileAbout] deinit")
    }
    
    @IBAction func didTapSave(_ sender: UIButton) {
        updateAbout()
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        goBack()
    }
}

extension EditProfileAbout {
    
    func updateAbout(animateButton: Bool = true) {
        btnSave.startAnimation()
        self.user.about = self.textView.text
        ProfileNetworkHelper.shared.updateAbout(about: self.textView.text) {[weak self] error in
            DispatchQueue.main.async {
                self?.btnSave.stopAnimation()
                if let err = error {
                    self?.showErrorWith(message: err.message)
                } else if (self?.user) != nil {
                    self?.goBack()
                }
            }
        }
    }
}

extension EditProfileAbout: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count < 2600{
            lblCountWords.text = "\(textView.text.count)/2600"
        }
        else{
            self.showErrorWith(message: "Text limit reached")
            return
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 2600
    }
}
