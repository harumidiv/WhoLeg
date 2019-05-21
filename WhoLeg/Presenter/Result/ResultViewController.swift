//
//  ResultViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    let score: Int
    init(score: Int) {
        self.score = score
        super.init(nibName: String(describing: ResultViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        if score == 10 {
            self.view = ResultGoodView()
        } else if score > 5 {
            self.view = ResultNormalView()
        } else {
            self.view = ResultBadView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "スコア"
        self.navigationItem.hidesBackButton = true
        print("score:\(score)")
    }
}
