//
//  BaseCollectionViewCell.swift
//  Obvios
//
//  Created by Binoy Vijayan on 08/12/22.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    static var id: String {
        let name = String(describing: self)
        return name
    }
    
    static var nib: UINib {
        let name = String(describing: self)
        let nib = UINib(nibName: name, bundle: Bundle(for: BaseCollectionViewCell.self))
        return nib
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
