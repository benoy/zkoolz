//
//  ZKOverlayView.swift
//  zkoolz
//
//  Created by Binoy Vijayan on 21/06/24.
//

import UIKit

class ZKOverlayView: ZKCustomView {
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let gesture =  UITapGestureRecognizer(target: self, action: #selector(touchOnOverlay))
        self.addGestureRecognizer(gesture)
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
    }
    
    func show() {
        
        DispatchQueue.main.async {
            let window = ZKAppController.shared.window!
            window.rootViewController?.view.addSubview(self)
            window.bringSubviewToFront(self)
        }
        
    }
    
    func hide() {
        
        let animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut) {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        }
        animator.startAnimation()
        animator.addCompletion { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc func touchOnOverlay(gesture: UIGestureRecognizer) {
        hide()
    }
}
