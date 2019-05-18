//
//  QuizView.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

class QuizView: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .orange
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        return nil
    }
}
