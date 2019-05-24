//
//  UILabel+IB.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/24.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

extension UILabel {
    @objc dynamic var textAppColor: String {
        get {
            return ""
        }
        set {
            let appColor = UIColor.AppColor(rawValue: newValue)
            guard let color = appColor else {
                return
            }
            textColor = UIColor(appColor: color)
        }
    }
}
