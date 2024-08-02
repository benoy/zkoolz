//
//  BaseView.swift
//  Survey
//
//  Created by Binoy Vijayan on 17/05/23.
//

import UIKit

class BaseView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    
    static var nibName: String {
        let name = String(describing: self)
        return name
    }
    
    override init(frame: CGRect) {
       super.init(frame: frame)
       commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.fixInView(self)
    }
}

extension UIView {
    
    func fixInView(_ container: UIView!) -> Void {
        container.backgroundColor = .clear
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
    
    func add(corner: CGFloat,
             borderColor: UIColor = UIColor.clear,
             borderWidth: CGFloat = 0) {
        
        layer.cornerRadius = corner
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
    
    func makeTopCornersRound(radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: radius, height: radius))

        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }

}


