//
//  ZKCustomView.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 21/06/24.
//

import UIKit

class ZKCustomView: UIView {

    var contentView: UIView?

    override init(frame: CGRect) {
       super.init(frame: frame)
       commonInit()
    }

    required init?(coder: NSCoder) {
       super.init(coder: coder)
       commonInit()
    }
    
    private func commonInit() {
       let bundle = Bundle(for: type(of: self))
       let nibName = String(describing: type(of: self))
       let nib = UINib(nibName: nibName, bundle: bundle)
       guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
           return
       }
       contentView = view
        contentView?.backgroundColor = UIColor.clear
       contentView?.frame = self.bounds
       contentView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       self.addSubview(contentView!)
    }

}
