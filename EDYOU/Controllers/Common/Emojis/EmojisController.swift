//
//  UniversityPickerController.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit

class EmojisController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var cstContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var viewContainer: VariableCornerRadiusView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var viewTapable: UIView!
    @IBOutlet weak var cstViewContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    
    
    // MARK: - Properties
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var currentPositionTouched: CGPoint?
    private var mid = CGPoint.zero
    private var top = CGPoint.zero
    var completion:  ((_ selected: String) -> Void)?
    
    var adapter: EmojisAdapter!
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cstContainerViewBottom.constant = -1000
        setupUI()
        
        let screenBound = UIScreen.main.bounds
        mid = CGPoint(x: 0, y: (screenBound.height / 3))
        top = CGPoint(x: 0, y: Application.shared.safeAreaInsets.top)
        self.cstViewContainerHeight.constant = self.view.frame.height - mid.y - Application.shared.safeAreaInsets.bottom
        
        adapter = EmojisAdapter(collectionView: collectionView)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveLinear, animations: {
            self.bgView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.cstContainerViewBottom.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
        self.collectionView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShowNotification(_ sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardWillChangeFrame(to: endFrame)
            }
        }
    }
    @objc private func keyboardWillHideNotification(_ sender: NSNotification) {
        keyboardWillChangeFrame(to: CGRect.zero)
    }
    
    
    func keyboardWillChangeFrame(to frame: CGRect) {
        
        if frame.height > 0 {
            cstContainerViewBottom.constant = frame.height - Application.shared.safeAreaInsets.bottom
        } else {
            cstContainerViewBottom.constant = frame.height
        }
        view.layoutIfNeeded(true)
        
    }
    
    
    init(completion: @escaping (_ selected: String) -> Void) {
        super.init(nibName: EmojisController.name, bundle: nil)
        

        self.completion = completion
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    deinit {
        print("[DataPickerController] deinit")
    }
    
    
    
    // MARK: - Actions
    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: view)
        
        if panGesture.state == .began {
            currentPositionTouched = panGesture.location(in: view)
        } else if panGesture.state == .changed {
            let minY = -1 * viewContainer.frame.origin.y
            let y = translation.y < minY ? minY : translation.y
            view.frame.origin = CGPoint(
                x: 0,
                y: y
            )
        } else if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: view)
            
            if velocity.y >= 1000 {
                UIView.animate(withDuration: 0.2
                               , animations: {
                                self.view.frame.origin = CGPoint(
                                    x: self.view.frame.origin.x,
                                    y: self.view.frame.size.height
                                )
                               }, completion: { (isCompleted) in
                                if isCompleted {
                                    self.dismiss(animated: false, completion: nil)
                                }
                               })
            } else {
                let containerYOnScreen = viewContainer.frame.origin.y + self.view.frame.origin.y
                let distianceFromTop = containerYOnScreen - top.y
                let distianceFromMid = mid.y - containerYOnScreen
                
                if distianceFromTop < distianceFromMid {
                    self.cstViewContainerHeight.constant = self.view.frame.height - top.y - Application.shared.safeAreaInsets.bottom
                } else {
                    self.cstViewContainerHeight.constant = self.view.frame.height - mid.y - Application.shared.safeAreaInsets.bottom
                }
                
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.layoutIfNeeded()
                    self.view.frame.origin = .zero
                })
            }
        }
    }
    
    
    // MARK: - Utility Methods
    
    func setupUI() {
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        self.viewTapable.addGestureRecognizer(gesture)
        self.view.backgroundColor = .clear
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer!)
    }
    
    @objc func dismissViewController() {
        dismissView()
    }
    func dismissView(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView.backgroundColor = UIColor.clear
            self.cstContainerViewBottom.constant = -1000
            self.view.layoutIfNeeded()
        }) { (_) in
            self.dismiss(animated: false, completion: nil)
            completion?()
        }
    }
}
