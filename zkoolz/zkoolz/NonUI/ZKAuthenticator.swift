//
//  ZKAuthenticator.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 14/06/24.
//

import Foundation
import FirebaseAuth

enum ZKAuthError: Error {
    
    case invalidPhone
    case invalidOTP
    case serverDown
    case unknown
    case none
    
}

protocol ZKAuthenticatable {
    func sendOTP(phone: String, completion: @escaping (Result<Bool, ZKAuthError>) -> Void)
    func validate(otp: String, completion: @escaping (Result<(String, String), ZKAuthError>) -> Void)
}

class ZKAuthenticator: ZKAuthenticatable {
    
    private var verificationId: String = ""
    
    func sendOTP(phone: String, completion: @escaping (Result<Bool, ZKAuthError>) -> Void) {
        
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phone, uiDelegate: nil) { verificationID, error in
                
                if let error = error {
                    print(error.localizedDescription)
                    completion(.failure(ZKAuthError.invalidPhone) )
                } else {
                    self.verificationId = verificationID ?? ""
                    completion(.success(true))
                }
          }
    }
    
    func validate(otp: String, completion: @escaping (Result<(String, String), ZKAuthError>) -> Void) {
        
        let credential = PhoneAuthProvider.provider().credential(
          withVerificationID: verificationId,
          verificationCode: otp
        )
        Auth.auth().signIn(with: credential) {authResult, error in
            if let error = error {
                completion(.failure(ZKAuthError.invalidOTP) )
            } else {
                let authId = authResult?.user.uid ?? ""
                let phone = authResult?.user.phoneNumber ?? ""
                
                let result = (authId, phone)
                completion(.success(result))
            }
        }
    }
}
