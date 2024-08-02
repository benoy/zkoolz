//
//  ZKGlobal.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 15/06/24.
//

import Foundation

class ZKGlobal {
    
    static let shared = ZKGlobal()
    private init() {}
    
    var score: ZKScore?
}
