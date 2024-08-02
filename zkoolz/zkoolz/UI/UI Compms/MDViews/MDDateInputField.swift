//
//  MDDateInputField.swift
//  Postuz
//
//  Created by Binoy Vijayan on 04/08/22.
//

import Foundation
import UIKit



@IBDesignable class MDDateInputField: UIView {
    
    var didCompleteDate: (String) -> Void = { _ in }
    
    var dateFormat: String = "dd/mm/yyyy"
    var date: Date = Date()
    
    private let dayField: MDTextField = MDTextField(placeHolder: "DD")
    private let monthField: MDTextField = MDTextField(placeHolder: "MM")
    private let yearField: MDTextField = MDTextField(placeHolder: "YYYY")
    
    private let margin = 0.0
    private let width = 72.0
    
    init(date: Date = Date(), dateFormat: String = "dd/mm/yyyy") {
        super.init(frame: CGRect.zero)
        self.dateFormat = dateFormat
        self.date = date
        self.setLayout()
        self.setAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setLayout()
        self.setAppearance()
    }

    private func setLayout() {
        
        dayField.tag = 101
        monthField.tag = 102
        yearField.tag = 103
        dayField.delegate = self
        monthField.delegate = self
        yearField.delegate = self
        
        let slshLabel = UILabel()
        slshLabel.text = "/"
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(dayField)
        
        dayField.topAnchor.constraint(equalTo: topAnchor, constant: margin).isActive = true
        dayField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin).isActive = true
        dayField.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        dayField.widthAnchor.constraint(equalToConstant: width).isActive = true

        addSubview(monthField)
        monthField.topAnchor.constraint(equalTo: topAnchor, constant: margin).isActive = true
        monthField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin).isActive = true
        
        monthField.leftAnchor.constraint(equalTo: leftAnchor, constant: width).isActive = true
        monthField.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        addSubview(yearField)
        yearField.topAnchor.constraint(equalTo: topAnchor, constant: margin).isActive = true
        yearField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin).isActive = true
        yearField.leftAnchor.constraint(equalTo: leftAnchor, constant: (width * 2.0) + (margin)).isActive = true
        yearField.widthAnchor.constraint(equalToConstant: width + 12.0).isActive = true
    }
    
    private func setAppearance() {
        dayField.textAlignment = .center
        monthField.textAlignment = .center
        yearField.textAlignment = .center
    }
}


extension MDDateInputField: MDTextFieldCustomizable {
   
    func textField(_ textField: MDTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty {
            return true
        }
        let txt = textField.text + string
        let num = Int(txt) ?? 0
        let tag = textField.tag
        switch tag {
        case 101:
            
            if txt.count == 2 {
                
                if num > 31 {
                    textField.text = "01"
                    return false
                } else {
                
                    defer {
                        textField.text = txt
                        let vw = self.viewWithTag(102) 
                        vw?.becomeFirstResponder()
                    }
                    return true
                    
                }
            } else if txt.count < 2 {
                return true
            } else {
                return false
            }
            
        case 102:
            if txt.count == 2 {
                
                if num > 12 {
                    textField.text = "01"
                    return false
                } else {
                
                    defer {
                        textField.text = txt
                        let vw = self.viewWithTag(103)
                        vw?.becomeFirstResponder()
                    }
                    return true
                    
                }
            } else if txt.count < 2 {
                return true
            } else {
                return false
            }
        case 103:
            if range.location > 3 {
                
                defer {
                    let _ = textField.resignFirstResponder()
                }
                return false
            }
            let year = Calendar.current.component(.year, from: Date())
            if num > year {
                return false
            }
            
        default:
            return true
        }
        
       return true
    }
}
