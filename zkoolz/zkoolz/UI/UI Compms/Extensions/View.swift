//
//  View.swift
//  Postuz
//
//  Created by Binoy Vijayan on 01/09/22.
//

import UIKit

extension UIView {
    
    func makeCard(cornerRadius: CGFloat = 10) {
        
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.30
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        
    }
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        set{
            self.layer.cornerRadius = newValue
        }
        get {
            return self.layer.cornerRadius
        }
    }
}
