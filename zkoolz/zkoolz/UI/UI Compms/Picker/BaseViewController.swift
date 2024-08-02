//
//  BaseViewController.swift
//  Survey
//
//  Created by Binoy Vijayan on 13/04/23.
//

import UIKit

class BaseViewController: UIViewController {

    
    var includedViewsinTap: [UIView]?
    
    class var instance: Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T(nibName: String(describing: T.self), bundle: Bundle(for: T.self))
        }
        return instantiateFromNib()
    }

    func okAlert(title: String = "",
                 message: String,
                 completion: (() -> Void)? = nil ) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            completion?()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func yesNoAlert(title: String = "",
                        message: String,
                        callback: @escaping (Bool, UIAlertController?) -> Void ) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .default,
                                      handler: { action in
            callback(true, alert)
        }))
        
        alert.addAction(UIAlertAction(title: "No",
                                      style: .default,
                                      handler: { action in
            
            callback(false, alert)
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction private func didTapBack(button: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
       
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
         willShowKeyboard(notification: notification)
    }

    @objc func keyboardWillHide(notification: NSNotification){
        willHideKeyboard(notification: notification)
    }
    
    func willShowKeyboard(notification: NSNotification) {
        
        if let uInfo = notification.userInfo {
            
            let frm = uInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            let ht = frm?.cgRectValue.height ?? 0.0
            let duration = (uInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.1
           showKeyboard(with: ht, animationDuration: duration)
        }
    }
    
    func willHideKeyboard(notification: NSNotification) {
        if let uInfo = notification.userInfo {
            let duration = (uInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.1
            hideKeyboard(with: 8, animationDuration: duration)
        }
    }
    
    func showKeyboard(with height: Double, animationDuration: Double) {
        
    }
    
    func hideKeyboard(with height: Double, animationDuration: Double) {
        
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
    }
}

extension BaseViewController {
    
    func hideKeyboardWhenTappedAround(excludedViews: [UIView]? = nil) {
        includedViewsinTap = excludedViews
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(dismissKeyboard( _:)));
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    
    @objc func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        
        guard let exVws = includedViewsinTap  else {
            view.endEditing(true)
            return
        }
        for vw in exVws {
            if vw.frame.contains(gesture.location(in: vw.superview)) {
               return
            }
        }
        
        view.endEditing(true)

       
    }
}
