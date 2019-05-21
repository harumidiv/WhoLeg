//
//  RoundView.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/21.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

@IBDesignable
class RoundView: UIView {
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
    private func setupAttribute(){
        layer.cornerRadius = self.frame.height/2
        backgroundColor = UIColor(appColor: .c1)
    }

}
