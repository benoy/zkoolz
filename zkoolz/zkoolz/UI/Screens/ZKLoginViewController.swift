//
//  EPLoginViewController.swift
//  Postuz
//
//  Created by Binoy Vijayan on 31/07/22.
//

import UIKit
import FirebaseAuth
import CoreLocation

class ZKLoginViewController: ZKBaseViewController {
    
    @IBOutlet private var nameField: MDTextField!
    @IBOutlet private var phField: MDTextField!
    @IBOutlet private var otpField: MDOtpField!
    @IBOutlet private var sendOtpButton: UIButton!
    @IBOutlet private var timerLabel: UILabel!
    
    @IBOutlet private var codeTxtField: MDTextField!

    
    private var timer: Timer?
    private var counter: Int = 0
    private var verificationId: String = ""
    private var userName: String = ""
    private let endCount = 30
    
    var  authenticator: ZKAuthenticatable = ZKAuthenticator()
    
    var viewModel: ZKLoginViewModel = ZKLoginViewModel()
    
    
    
    override func viewDidLoad() {
        otpField.isHidden = true
        super.viewDidLoad()
        
        codeTxtField.keypadType = .phoneCode
        
        viewModel.checkLocationAuthorization()
        
        viewModel.didUpdatePhoneCode = {  [weak self] codes in
            self?.codeTxtField?.setFlag(phoneCode: codes.1)
        }
        
    }

    @IBAction private func didTapSendOtp(button: UIButton) {
        
        viewModel.sendOtp(name: nameField.text,
                          phoneCode: codeTxtField.text,
                          phone: phField.text,
                          completion: { [weak self] errStr in
            
            guard let errStr = errStr  else {
                
                self?.showOtpField()
                return
            }
            self?.showOkAlert(message: errStr)
        })
    }
    
    private func signIn(code: String) {
       
        viewModel.signIn(otp: code, completion: { [weak self] errStr in
            
            if let errStr = errStr {
                self?.showOkAlert(message: errStr)
            } else {
                DispatchQueue.main.async {
                    ZKAppController.shared.showHomeScreen()
                }
                
            }
        })
    }
    
    
    private func showOtpField() {
        resetCounter()
        
        otpField.isHidden = false
        timerLabel.isHidden = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [unowned self] tmr in
            
            self.counter += 1
            DispatchQueue.main.async {
                self.timerLabel.text = "\(self.counter)"
            }
            
            if self.counter >= self.endCount {
                DispatchQueue.main.async {
                    self.resetCounter()
                }
            }
        })
        
        otpField.didCompleteOtp = { [weak self] otpOtp in
            
            self?.signIn(code: otpOtp)
            
            DispatchQueue.main.async {
                self?.otpField.isHidden = true
                self?.resetCounter()
            }
        }
        
        
    }
    
    private func resetCounter() {
        
        timer?.invalidate()
        counter = 0
        timer = nil;
        timerLabel.text = ""
        otpField.resetFileds()
        otpField.isHidden = true
        
    }
    
   
}



