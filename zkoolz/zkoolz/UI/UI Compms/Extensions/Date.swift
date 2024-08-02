//
//  Date.swift
//  Postuz
//
//  Created by Binoy Vijayan on 15/08/22.
//

import Foundation

extension Date {
    var string: String {
        let formater = DateFormatter()
        formater.dateFormat = "dd/mm/yyyy"
        formater.timeZone = TimeZone(abbreviation: "UTC")
        let str = formater.string(from: self)
        return str
    }
    
    var stringWithTime: String {
        let formater = DateFormatter()
        formater.dateFormat = "dd/mm/yyyy HH:mm:ss"
        formater.timeZone = TimeZone(abbreviation: "UTC")
        let str = formater.string(from: self)
        return str
    }
}
