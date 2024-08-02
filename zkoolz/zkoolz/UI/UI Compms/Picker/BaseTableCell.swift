//
//  BaseTableCell.swift
//  PayPay
//
//  Created by Binoy Vijayan on 28/10/22.
//

import UIKit

class BaseTableCell: UITableViewCell {

    static var id: String {
        let name = String(describing: self)
        return name
    }
    
    static var nib: UINib {
        let name = String(describing: self)
        let nib = UINib(nibName: name, bundle: Bundle(for: BaseTableCell.self))
        return nib
    }
}
