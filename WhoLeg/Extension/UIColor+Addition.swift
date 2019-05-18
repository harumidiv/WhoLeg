//
//  UIColor+Addition.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

extension UIColor {
    enum AppColor: String {
        case c1
        case c2
        case c3
        case c4
        case c5
        case c6
        
        var hex: String {
            switch self {
            case .c1:
                return "#00AECA"
            case .c2:
                return "#BFD833"
            case .c3:
                return "#5C5142"
            case .c4:
                return "#808080"
            case .c5:
                return "#F7F7F7"
            case .c6:
                return "#FFFFFF"
            }
        }
    }
    
    convenience init(hex: String, alpha: CGFloat) {
        var rgbHex = hex
        if rgbHex.prefix(1) == "#" {
            rgbHex = rgbHex.replacingOccurrences(of: "#", with: "")
        }
        let v = rgbHex.map { String($0) } + Array(repeating: "0", count: max(6 - hex.count, 0))
        let r = CGFloat(Int(v[0] + v[1], radix: 16) ?? 0)
        let g = CGFloat(Int(v[2] + v[3], radix: 16) ?? 0)
        let b = CGFloat(Int(v[4] + v[5], radix: 16) ?? 0)
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: alpha)
    }
    
    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
    
    convenience init(appColor: AppColor) {
        self.init(hex: appColor.hex, alpha: 1.0)
    }
}
