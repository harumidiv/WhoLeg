//
//  UIView+IB.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/10/13.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

protocol NibInitializable {}

extension NibInitializable where Self: UIView {
    static func loadNib() -> Self {
        let name = className
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil)![0] as! Self
    }
}

extension UIView: NibInitializable {}
