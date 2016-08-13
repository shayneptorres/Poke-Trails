//
//  MaterialButton.swift
//  PKMN Go Find
//
//  Created by Shayne Torres on 7/18/16.
//  Copyright © 2016 Shayne Torres. All rights reserved.
//

import UIKit

class MaterialButton: UIButton {
    let SHADOW_COLOR: CGFloat = 157.0/255.0
    var chosen = false
    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue:SHADOW_COLOR, alpha:0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
    }
}
