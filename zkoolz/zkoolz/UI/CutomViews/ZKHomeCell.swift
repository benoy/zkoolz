//
//  ZKHomeCell.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 19/06/24.
//

import UIKit

class ZKHomeCell: ZKBaseCell {
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var iconView: UIImageView!
    
    var cellTitle: String =  "" {
        didSet {
            label.text = cellTitle
        }
    }
    
    var imageName: String = "" {
        didSet {
            
            if imageName.isEmpty {
                iconView.image = UIImage(systemName: "photo")
            } else {
                iconView.image = UIImage(named: imageName)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
