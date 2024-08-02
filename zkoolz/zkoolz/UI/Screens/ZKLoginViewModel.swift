//
//  ZKLoginViewModel.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 14/06/24.
//

import Foundation
import CoreLocation

@propertyWrapper
struct PlusFirst {
    private var value: String = ""

    var wrappedValue: String {
        get { value }
        set {
            
            let comps = newValue.components(separatedBy: ":")
            
            if !newValue.hasPrefix("+") {
                value = "+\(newValue)"
            } else {
                value = newValue
            }
        }
    }

    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }
}


class ZKLoginViewModel: NSObject {

    
    private var  authenticator: ZKAuthenticatable!
    private var dbManager: ZKDBManageable!
    private let locationManager = CLLocationManager()
    
    
    private var userName: String = ""
    
    var didUpdatePhoneCode: ((String, String)) -> Void = { _ in }
    
    @PlusFirst var code: String = ""

    
    private var phoneNumber: String = "" {
        didSet {
            ZKDBManager.saveUser(phone: phoneNumber)
        }
    }
    private var authId: String = "" {
        didSet {
            ZKDBManager.saveUserAuth(id: authId)
        }
    }
    
    init(authenticator: ZKAuthenticatable = ZKAuthenticator(),
         dbManager: ZKDBManageable = ZKDBManager()) {
        self.authenticator = authenticator
        self.dbManager = dbManager
        super.init()
    }
    
    func sendOtp(name: String, 
                 phoneCode: String,
                 phone: String,
                 completion: @escaping (String?) -> Void ) {
        
        if name.isEmpty, name.count < 3 {
            completion("Invalid name.")
            return
        }
        
       
        if !phone.isValidPhone {
            completion("Invalid phone.")
            return
        }
        
        userName = name
        code = phoneCode
        authenticator.sendOTP(phone: "\(self.code) \(phone)", completion: { result in
            if case .success(_) = result {
                completion(nil)
            } else if case .failure(_) = result {
                completion("Something went wrong, please try again later.")
            }
        })
    }
    
    func signIn(otp: String, completion: @escaping (String?) -> Void) {
        authenticator.validate(otp: otp, completion: { [weak self] result in
            switch result {
            case .failure(let error):
                completion(error.localizedDescription)
            case .success(let data):
                self?.authId = data.0
                self?.phoneNumber = data.1
                self?.saveUser(completion)
                
            }
        })
    }
    
    private func saveUser(_ completion: @escaping (String?) -> Void) {
        let user = ZKUser(authId: authId, name: userName , phone: phoneNumber )
        Task {
            let result = await dbManager.save(user: user)
            if result.0 == true && result.1 == nil {
                completion(nil)
            } else {
                completion(result.1)
            }
            
        }
    }
    
    func checkLocationAuthorization() {
        
        locationManager.delegate = self
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            case .restricted, .denied:
                print("Location access restricted or denied.")
                // Handle appropriately, maybe show an alert to the user
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.requestLocation()
            @unknown default:
                fatalError("Unknown authorization status")
            }
        
    }
    
    func fetchCountryCode(for location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first, let countryCode = placemark.isoCountryCode {
                self.setCountryCode(countryCode)
            }
        }
    }
    
    func setCountryCode(_ countryCode: String) {
        
        let phCd = countryPhoneCodes[countryCode] ?? ""
        code = phCd
//        let flgStr = String.flagEmoji(forCountryCode: countryCode)
//        didUpdatePhoneCode("\(flgStr) : \(code)")
        didUpdatePhoneCode((countryCode, code))
    }
    
}

extension ZKLoginViewModel: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           switch status {
           case .notDetermined:
               // Authorization status not determined, request when in use authorization
               locationManager.requestWhenInUseAuthorization()
           case .restricted, .denied:
               print("Location access restricted or denied.")
               // Handle appropriately, maybe show an alert to the user
           case .authorizedWhenInUse, .authorizedAlways:
               locationManager.requestLocation()
           @unknown default:
               fatalError("Unknown authorization status")
           }
       }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       if let location = locations.first {
           fetchCountryCode(for: location)
       }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                print("Location unknown.")
            case .denied:
                print("Location access denied.")
            case .network:
                print("Network issues.")
            default:
                print("Location error: \(clError.localizedDescription)")
            }
        } else {
            print("Failed to get user's location: \(error.localizedDescription)")
        }
    }
}




let codes = [
                "US-1",
                "IN-91",
                "AX-358",
             "AQ-672",
             "AS-1684",
             "AI-1264",
             "AG-1268",
             "IL-972",
             "AF-93",
             "AL-355",
             "DZ-213",
             "AD-376",
             "AO-244",
             "AR-54",
             "AM-374",
             "AW-297",
             "AU-61",
             "AT-43",
             "AZ-994",
             "BS-1242",
             "BH-973",
             "BD-880",
             "BB-1246",
             "BY-375",
             "BE-32",
             "BZ-501",
             "BJ-229",
             "BM-1441",
             "BT-975",
             "BA-387",
             "BW-267",
             "BR-55",
             "IO-246",
             "BG-359",
             "BES-599",
             "BF-226",
             "BI-257",
             "BQ-599",
             "BV-55",
             "KH-855",
             "CM-237",
             "CA-1",
             "CV-238",
             "CW-599",
             "KY-1345",
             "CF-236",
             "TD-235",
             "TF-262",
             "CL-56",
             "CN-86",
             "CX-61",
             "CO-57",
             "KM-269",
             "CG-242",
             "CK-682",
             "CR-506",
             "HR-385",
             "CU-53",
             "CY-357",
             "CZ-420",
             "DK-45",
             "DJ-253",
             "DM-1767",
             "DO-1",
             "HM-334",
             "EC-593",
             "EG-20",
             "SV-503",
             "GQ-240",
             "ER-291",
             "EE-372",
             "EH-212",
             "ET-251",
             "FO-298",
             "FJ-679",
             "FI-358",
             "FR-33",
             "GF-594",
             "PF-689",
             "GA-241",
             "GM-220",
             "GE-995",
             "DE-49",
             "GH-233",
             "GI-350",
             "GR-30",
             "GL-299",
             "GD-1473",
             "GP-590",
             "GU-1671",
             "GT-502",
             "GN-224",
             "GW-245",
             "GY-592",
             "HT-509",
             "HN-504",
             "HU-36",
             "IS-354",
             
             "ID-62",
             "IQ-964",
             "IE-353",
             "IT-39",
             "JM-1876",
             "JP-81",
             "JO-962",
             "KZ-7",
             "KE-254",
             "KI-686",
             "KW-965",
             "KG-996",
             "LV-371",
             "LB-961",
             "LS-266",
             "LR-231",
             "LI-423",
             "LT-370",
             "LU-352",
             "MG-261",
             "MW-265",
             "MY-60",
             "MV-960",
             "ML-223",
             "MT-356",
             "MH-692",
             "MQ-596",
             "MR-222",
             "MU-230",
             "YT-262",
             "MX-52",
             "MC-377",
             "MN-976",
             "ME-382",
             "MS-1664",
             "MA-212",
             "MM-95",
             "NA-264",
             "NR-674",
             "NP-977",
             "NL-31",
             "AN-599",
             "NC-687",
             "NZ-64",
             "NI-505",
             "NE-227",
             "NG-234",
             "NU-683",
             "NF-672",
             "MP-1670",
             "NO-47",
             "OM-968",
             "PK-92",
             "PW-680",
             "PA-507",
             "PG-675",
             "PY-595",
             "PE-51",
             "PH-63",
             "PL-48",
             "PT-351",
             "PR-1",
             "QA-974",
             "RO-40",
             "RW-250",
             "WS-685",
             "SM-378",
             "SA-966",
             "SN-221",
             "RS-381",
             "SC-248",
             "SL-232",
             "SG-65",
             "SX-1721",
             "SK-421",
             "SI-386",
             "SB-677",
             "ZA-27",
             "GS-500",
             "ES-34",
             "LK-94",
             "SD-249",
             "SR-597",
             "SZ-268",
             "SE-46",
             "CH-41",
             "TJ-992",
             "TH-66",
             "TG-228",
             "TK-690",
             "TO-676",
             "TT-1868",
             "TN-216",
             "TR-90",
             "TM-993",
             "TC-1649",
             "TV-688",
             "UG-256",
             "UA-380",
             "AE-971",
             "GB-44",
             "UY-598",
             "UZ-998",
             "VU-678",
             "WF-681",
             "YE-967",
             "ZM-260",
             "ZW-263",
             "BO-591",
             "BN-673",
             "CC-61",
             "CD-243",
             "CI-225",
             "FK-500",
             "GG-44",
             "VA-379",
             "HK-852",
             "IR-98",
             "IM-44",
             "JE-44",
             "KP-850",
             "KR-82",
             "LA-856",
             "LY-218",
             "MO-853",
             "MK-389",
             "FM-691",
             "MD-373",
             "MZ-258",
             "PS-970",
             "PN-872",
             "RE-262",
             "RU-7",
             "BL-590",
             "SH-290",
             "KN-1869",
             "LC-1758",
             "MF-590",
             "PM-508",
             "VC-1784",
             "ST-239",
             "SO-252",
             "SS-211",
             "SJ-47",
             "SY-963",
             "TW-886",
             "TZ-255",
             "TL-670",
             "UM-1",
             "VE-58",
             "VN-84",
             "VG-1284",
             "VI-1340",
             "XK-383"
]
