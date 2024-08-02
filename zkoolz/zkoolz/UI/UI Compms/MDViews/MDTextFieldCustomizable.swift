//
//  MDTextFieldCustomizable.swift
//  MDTextField
//
//  Created by Binoy Vijayan on 15/06/22.
//

import UIKit

public protocol MDTextFieldCustomizable {
    
    
    func textFieldShouldBeginEditing(_ textField: MDTextField) -> Bool // return NO to disallow editing.

    
    func textFieldDidBeginEditing(_ textField: MDTextField) // became first responder

    
    func textFieldShouldEndEditing(_ textField: MDTextField) -> Bool // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end

    
    func textFieldDidEndEditing(_ textField: MDTextField) // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called

    
    func textFieldDidEndEditing(_ textField: MDTextField, reason: UITextField.DidEndEditingReason) // if implemented, called in place of textFieldDidEndEditing:
    
    func textField(_ textField: MDTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool // return NO to not change text
    
    
    func textFieldDidChangeSelection(_ textField: MDTextField)
    
    
    func textFieldShouldClear(_ textField: MDTextField) -> Bool // called when clear button pressed. return NO to ignore (no notifications)
    
    func textFieldShouldReturn(_ textField: MDTextField) -> Bool // called when 'return' key pressed. return NO to ignore.
}

extension MDTextFieldCustomizable {
 
    func textFieldShouldBeginEditing(_ textField: MDTextField) -> Bool { return true }

    
    func textFieldDidBeginEditing(_ textField: MDTextField) { }

    
    func textFieldShouldEndEditing(_ textField: MDTextField) -> Bool { return true}

    
    func textFieldDidEndEditing(_ textField: MDTextField) { }

    
    func textFieldDidEndEditing(_ textField: MDTextField, reason: UITextField.DidEndEditingReason) { }
    
    func textField(_ textField: MDTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { return true}
    
    
    func textFieldDidChangeSelection(_ textField: MDTextField) { }
    
    
    func textFieldShouldClear(_ textField: MDTextField) -> Bool { return true}
    
    func textFieldShouldReturn(_ textField: MDTextField) -> Bool { return true }
}
