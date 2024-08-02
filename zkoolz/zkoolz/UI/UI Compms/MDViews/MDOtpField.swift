//
//  MDOtpField.swift
//  Postuz
//
//  Created by Binoy Vijayan on 01/08/22.
//

import UIKit

var shouldChangeTheFiled: (Int, String) -> Void = { _, _ in }

class MDOtpTextField: UITextField, UITextFieldDelegate {

    var index = -1
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.borderStyle = .line
        self.keyboardType = .numberPad
        self.delegate = self
        self.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0{
            shouldChangeTheFiled(index + 1, string)
            return true
        } else {
            return false
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
}

@IBDesignable class MDOtpField: UIView {
    
    var didCompleteOtp: (String) -> Void = { _ in }
    
    private var txtFields = [MDOtpTextField]()

    private var _digitCount = 4 {
        
        didSet {
            self.setLayout()
        }
    }
    @IBInspectable var digitCount: Int {
        
        set {
            _digitCount = newValue
        }
        
        get {
            return _digitCount
        }
        
    }
    
    public init(digitCount: Int) {
        super.init(frame: CGRect.zero)
        _digitCount = digitCount
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }

    private func setLayout() {
        
        txtFields = [MDOtpTextField]()
        for i in 0..<_digitCount {
            let textFld = MDOtpTextField(frame: .zero)
            textFld.index = i
            txtFields.append(textFld)
        }
        
        txtFields.first?.becomeFirstResponder()
        
        
        shouldChangeTheFiled = { [unowned self] idx, str in
            
            if idx < self.txtFields.count {
                let txtFld = self.txtFields[idx]
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    txtFld.becomeFirstResponder()
                })
                
            } else {
                var combinedStr = self.txtFields.map { $0.text ?? "" }.reduce("", { $0 + $1})
                combinedStr += str
                self.didCompleteOtp(combinedStr)
            }
            
        }
        
        let hStack = UIStackView(arrangedSubviews: txtFields)
        hStack.axis = .horizontal
        hStack.spacing = 16
        hStack.distribution = .fillEqually
        hStack.alignment = .center
        addSubview(hStack)
        
        hStack.translatesAutoresizingMaskIntoConstraints = false;
        hStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        hStack.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        hStack.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }
    
    func resetFileds() {
        for fld in self.txtFields { fld.text = "" }
        self.txtFields.first?.becomeFirstResponder()
    }
    
    private func setAppearance() {
        
        
    }
}
