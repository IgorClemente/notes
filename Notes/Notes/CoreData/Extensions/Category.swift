//
//  Category.swift
//  Notes
//
//  Created by MACBOOK AIR on 26/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit

extension Category {
    
    var color: UIColor? {
        get {
            guard let hex = colorAsHex else { return nil }
            return UIColor(hex: hex)
        }
        
        set(newColor) {
            if let newColor = newColor {
                colorAsHex = newColor.toHex
            }
        }
    }
}
