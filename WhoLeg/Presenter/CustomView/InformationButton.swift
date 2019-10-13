//
//  InformationButton.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/10/13.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

@IBDesignable
class InformationButton: QuizOptionButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAttribute()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAttribute()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupAttribute()
    }

    override func setupAttribute() {
        super.setupAttribute()
        layer.cornerRadius = 5
        backgroundColor = UIColor(appColor: .c1)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20.0)
    }
}
