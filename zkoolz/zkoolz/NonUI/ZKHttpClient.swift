//
//  ZKHttpClient.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 18/06/24.
//

import Foundation

enum ZKHttpError: Error {
    case invalidUrl
    case resourceNotAvailable
    case unkown
}

enum ZKHttpMethod: String {
    
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol ZKHttpClientProtocol {
    func get(usrlString: String) async -> (Data?, ZKHttpError?)
}

class ZKHttpClient: ZKHttpClientProtocol {
    
    func get(usrlString: String) async  -> (Data?, ZKHttpError?) {
        
        guard let ur = URL(string: usrlString) else { return (nil, ZKHttpError.invalidUrl) }
        let result = try? await URLSession.shared.data(from: ur)
        if let data = result?.0 {
            return (data, nil )
        }
        
        return (nil, ZKHttpError.resourceNotAvailable )
    }
}
