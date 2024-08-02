//
//  ZKHomeViewModel.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 19/06/24.
//

import Foundation

class ZKHomeViewModel {
    
    var rowsCount: Int {
        ZKGameLevel.array.count
    }
    
    func item(at: Int) -> String {
        return ZKGameLevel.array[at].rawValue
    }
    
    func level(at: Int) -> ZKGameLevel {
        return ZKGameLevel.array[at]
    }
}

