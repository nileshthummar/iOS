//
//  GradientView.swift
//  Phunware
//
//  Created by Nilesh on 6/16/19.
//  Copyright © 2019 Nilesh. All rights reserved.
//

import UIKit
////Semi-transparent color layer over background-image for text visibility
class GradientView: UIView {
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)        
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor.clear.cgColor,
            UIColor.clear.cgColor
        ]
        backgroundColor = UIColor.clear
    }
}
