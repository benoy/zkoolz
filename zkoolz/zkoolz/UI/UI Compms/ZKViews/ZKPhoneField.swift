//
//  ZKPhoneField.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 25/06/24.
//

import UIKit

class ZKPhoneField: UITextField {
    
    private var leftLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    func setup() {
        self.keyboardType = .namePhonePad
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 20))
        leftLabel = UILabel(frame: view.bounds)
        leftLabel.font = UIFont.systemFont(ofSize: 14)
        leftLabel.textColor = .black
//        leftLabel.text = "+00"
        view.addSubview(leftLabel)
        self.leftView = view
        self.leftViewMode = .always
        setFlag()
    }
    
    func setFlag(countryCode: String = "US") {
        leftLabel.text = String.flagEmoji(forCountryCode: countryCode)
    }
}
