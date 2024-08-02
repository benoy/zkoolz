//
//  ZKAdConsentManager.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 22/06/24.
//

import Foundation

import GoogleMobileAds
import UserMessagingPlatform

//  APP ID :   ca-app-pub-2035911889726107~5018275692

// Unit Id :   ca-app-pub-2035911889726107/3221429558

class ZKAdConsentManager: NSObject {
    
    static let shared = ZKAdConsentManager()
    
    var canRequestAds: Bool {
        return UMPConsentInformation.sharedInstance.canRequestAds
    }
    
    var isPrivacyOptionsRequired: Bool {
        return UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required
    }
    
    // Helper method to call the UMP SDK methods to request consent information and load/present a
    // consent form if necessary.
    
    func gatherConsent( from consentFormPresentationviewController: UIViewController,
                        consentGatheringComplete: @escaping (Error?) -> Void) {
        
        let parameters = UMPRequestParameters()
        
        //For testing purposes, you can force a UMPDebugGeography of EEA or not EEA.
        let debugSettings = UMPDebugSettings()
        
        // debugSettings.geography = UMPDebugGeography.EEA
        parameters.debugSettings = debugSettings
        
        
        // Requesting an update to consent information should be called on every app launch.
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { requestConsentError in
            
            guard requestConsentError == nil else {
                return consentGatheringComplete(requestConsentError)
            }
            
            UMPConsentForm.loadAndPresentIfRequired(from: consentFormPresentationviewController) { loadAndPresentError in
                
                // Consent has been gathered.
                consentGatheringComplete(loadAndPresentError)
            }
        }
    }
    
    // Helper method to call the UMP SDK method to present the privacy options form.
    func presentPrivacyOptionsForm( from viewController: UIViewController,
                                    completionHandler: @escaping (Error?) -> Void) {
        UMPConsentForm.presentPrivacyOptionsForm( from: viewController, completionHandler: completionHandler)
    }
    
}
