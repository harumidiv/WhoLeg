//
//  TitleViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {

    private var model: TitleModel = TitleModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "だれのあし？"
        
        let json = model.getQuizJson()
        print(json.quiz[0].answer)
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.navigationController?.pushViewController(QuizViewController(), animated: true)
    }
}
