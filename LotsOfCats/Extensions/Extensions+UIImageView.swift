//
//  Extensions+UIImageView.swift
//  LotsOfCats
//
//  Created by Bobby on 1/7/22.
//

import Foundation
import UIKit

extension UIImageView {
    // Add this for alternative to the JGProgressHUD spinner
    private var activityIndicator: UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.tag = 5
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        activityIndicator.layer.zPosition = 10
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        
        let centerX = NSLayoutConstraint(item: self,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: activityIndicator,
                                         attribute: .centerX,
                                         multiplier: 1,
                                         constant: 0)
        let centerY = NSLayoutConstraint(item: self,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: activityIndicator,
                                         attribute: .centerY,
                                         multiplier: 1,
                                         constant: 0)
        
        self.addConstraints([centerX, centerY])
        return activityIndicator
    }
    
    private var gradient: CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.name = "loading-gradient"
        gradient.frame = self.bounds
        gradient.colors = [UIColor.darkGray.cgColor, UIColor.lightGray.cgColor]
        gradient.locations =  [-1.5, 1.5]
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.5, 0.0]
        animation.toValue = [0.0, 1.5]
        animation.duration = 1.0
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        gradient.add(animation, forKey: nil)
        return gradient
    }
    
    func addLoadingGradient() {
        self.layer.addSublayer(self.gradient)
        
    }
    
    func removeLoadingGradient(){
        for layer in self.layer.sublayers! {
            if layer.name == "loading-gradient" {
                layer.removeFromSuperlayer()
            }
        }
    }
}
