//
//  ResultBadView.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/21.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

@IBDesignable
class ResultBadView: UIView {
    @IBOutlet weak var label: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        loadFromNib()
    }
    private func loadFromNib() {
        let v = UINib(nibName: "ResultBadView", bundle: Bundle(for: ResultGoodView.self)).instantiate(withOwner: self, options: nil)[0] as! UIView
        v.frame = self.bounds
        addSubview(v)
    }
}
