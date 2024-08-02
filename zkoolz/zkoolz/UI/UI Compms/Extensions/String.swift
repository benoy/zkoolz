//
//  String.swift
//  Postuz
//
//  Created by Binoy Vijayan on 19/08/22.
//

import Foundation
import CryptoKit

extension String {
    
    var isValidEmail: Bool {
        let regularExpressionForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let testEmail = NSPredicate(format:"SELF MATCHES %@", regularExpressionForEmail)
        return testEmail.evaluate(with: self)
    }
    
    var isValidPhone: Bool {
        let mobileRegEx = "^[0-9]{10}$"
        let testPh = NSPredicate(format:"SELF MATCHES %@", mobileRegEx)
        return testPh.evaluate(with: self)
    }
    
    var hash: String {
        let data = Data(self.utf8)
        let hashed = SHA256.hash(data: data)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    static func flagEmoji(forCountryCode countryCode: String) -> String {
        let base: UInt32 = 127397
        var flagString = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            guard let scalarValue = UnicodeScalar(base + scalar.value) else { return "" }
            flagString.unicodeScalars.append(scalarValue)
        }
        return flagString
    }
}
