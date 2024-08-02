//
//  PickerCell.swift
//  Survey
//
//  Created by Binoy Vijayan on 17/05/23.
//

import UIKit

class PickerCell: BaseCollectionViewCell {

    
    @IBOutlet private weak var midTxtLbl: UILabel!

    var midText: String = "" {
        didSet {
            
            if !midText.isEmpty {
                let comps = midText.components(separatedBy: "-")
                let imgTxt = String.flagEmoji(forCountryCode:  comps[0])
                midTxtLbl.text = "\(imgTxt) - \(comps[1])"
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func highlightLabel() {
        midTxtLbl.textColor = UIColor.darkGray
    }
    
    func understateLabel() {
        midTxtLbl.textColor = UIColor.lightGray
    }
}
