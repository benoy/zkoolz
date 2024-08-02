//
//  MDTextField.swift
//  MDTextField
//
//  Created by Binoy Vijayan on 15/06/22.
//

import UIKit

enum MDTextFieldType {
    
    case `default`
    case phone
    case email
    case url
    case decimal
    case phoneCode
    
    
    var uiTextFieldType: UIKeyboardType {
        switch self {
        case .default:
            return .default
        case .email:
            return .emailAddress
        case .url:
            return .URL
        case .decimal:
            return .decimalPad
        case .phone:
            return .phonePad
        case .phoneCode:
            return .phonePad
        }
    }
}

@IBDesignable public final class MDTextField: UIView {
   
    private var _placeHolder: String = ""
    
    @IBInspectable  var placeHolder: String {
        set {
            _placeHolder = newValue
            if !_placeHolder.isEmpty {
                label.text = " \(_placeHolder) "
            } else {
                label.text = ""
            }
        }
        
        get {
            return _placeHolder
        }
    }
    
    public var editingColor: UIColor = UIColor.systemBlue
    public var delegate: MDTextFieldCustomizable?
    
    
    var text: String {
        get {
            return textField.text ?? ""
        }
        set {
            textField.text = newValue
            
            if newValue.isEmpty == false {
                DispatchQueue.main.async {
                    self.animateOnBiginEditing()
                }
            }
        }
    }
    
    
    var keypadType: MDTextFieldType = .default {
        didSet {
            textField.keyboardType = keypadType.uiTextFieldType
            if keypadType == .phoneCode {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 50))
                codeLabel = UILabel(frame: view.bounds)
                codeLabel.font = UIFont.systemFont(ofSize: 14)
                codeLabel.numberOfLines = 0
                view.addSubview(codeLabel)
                textField.leftView = view
                textField.leftViewMode = .always
            }
        }
    }
    
    var isSecure: Bool = false {
        didSet {
            textField.isSecureTextEntry = isSecure
        }
    }
    
    
    private var textField: UITextField = UITextField()
    private let label: UILabel = UILabel()
    private let boderView: UIView = UIView()
    private var lblLeftContraint: NSLayoutConstraint?
    private var viewHeight: CGFloat = 0
    
    private var codeLabel: UILabel!
    
    private var orgLblFrm: CGRect = .zero
    
    public init(placeHolder: String = "Text Field") {
        super.init(frame: CGRect.zero)
        self._placeHolder = placeHolder
        self.setLayout()
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setLayout()
        self.setAppearance()
    }
    
    public override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
 
    public override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    var textAlignment: NSTextAlignment {
        get {
            return textField.textAlignment
        }
        
        set {
            textField.textAlignment = newValue
        }
    }
    
    public func dismissKeyboard() {
        textField.resignFirstResponder()
    }
    
    private func setAppearance() {
        self.clipsToBounds = true
        boderView.layer.borderWidth = 1
        boderView.layer.borderColor = UIColor.darkGray.cgColor
        boderView.layer.cornerRadius = 6
        
        
        textField.delegate = self
        textField.font = .systemFont(ofSize: 14)
    
        
        label.sizeToFit()
        label.isHidden = false
        label.text = " \(_placeHolder) "
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = UIColor(argb: 0xFFFFE4FF)
        
        self.backgroundColor = .clear
    }
    
    func setFlag(phoneCode: String) {
        
        var temp = phoneCode
        if temp.hasPrefix("+") {
            temp.removeFirst()
        }
        
        self.text = "+\(temp)"
        let countryCodes =  phoneCodeToCountries[temp] ?? [String]()
        var str = ""
        for cds in countryCodes {
            str += String.flagEmoji(forCountryCode: cds)
        }
        codeLabel.text = str  
        
        
    }
    
    private func setLayout() {
        
        translatesAutoresizingMaskIntoConstraints = false
        boderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(boderView)
        boderView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        boderView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        boderView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        boderView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        boderView.addSubview(textField)
        textField.leftAnchor.constraint(equalTo: boderView.leftAnchor, constant: 8).isActive = true
        textField.rightAnchor.constraint(equalTo: boderView.rightAnchor, constant: -8).isActive = true
        textField.topAnchor.constraint(equalTo: boderView.topAnchor, constant: 16).isActive = true
        
        textField.bottomAnchor.constraint(equalTo: boderView.bottomAnchor, constant: -16).isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        lblLeftContraint = label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20)
        lblLeftContraint?.isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 24).isActive = false
        label.heightAnchor.constraint(equalToConstant: 18).isActive = true
        bringSubviewToFront(label)
    }
    
    private func animateOnBiginEditing() {
        let tp =  ((frame.size.height / 2) - 16.0) * -1 
        let lblWdth: CGFloat = label.frame.size.width
        let lft: CGFloat = (lblWdth / 7) * -1.0
        
        UIView.animate(withDuration: 0.2) {
            self.label.textColor = UIColor.black
            let pos = CGAffineTransform(translationX: lft, y: tp)
            let scale = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.label.transform = scale.concatenating(pos)
            self.label.textColor = self.editingColor
            self.boderView.layer.borderColor = self.editingColor.cgColor
            self.label.backgroundColor = UIColor(argb: 0xFFFFE4FF)
        }
    }
    
    private func animateOnEndEditing() {
        UIView.animate(withDuration: 0.2) {
            self.label.textColor = UIColor.lightGray
            self.label.transform = .identity
            self.boderView.layer.borderColor = UIColor.lightGray.cgColor
            self.label.backgroundColor = .clear
        }
    }
}

extension MDTextField: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        animateOnBiginEditing()
                
        return delegate?.textFieldShouldBeginEditing(self) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing(self)
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField.text?.isEmpty ?? false {
            animateOnEndEditing()
        }
        return delegate?.textFieldShouldEndEditing(self) ?? true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {

        delegate?.textFieldDidEndEditing(self)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        if keypadType == .phoneCode {
            setFlag(phoneCode: textField.text ?? "")
        }
        delegate?.textFieldDidEndEditing(self, reason: reason )
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        return delegate?.textField(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    public func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.textFieldDidChangeSelection(self)
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldClear(self) ?? true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn(self) ?? true
    }
}
