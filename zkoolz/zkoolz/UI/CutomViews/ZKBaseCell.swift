//
//  ZKBaseCell.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 19/06/24.
//

import UIKit

class ZKBaseCell: UITableViewCell {
    
    
    static var id: String {
        let name = String(describing: self)
        return name
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
