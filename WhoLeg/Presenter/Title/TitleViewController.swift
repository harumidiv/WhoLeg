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
    var jsonData: QuizInfo!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "だれのあし？"
        
        jsonData = model.getQuizJson()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.navigationController?.pushViewController(QuizViewController(quizData: jsonData, score: 0), animated: true)
    }
}
