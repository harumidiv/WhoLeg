//
//  TitleViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "だれのあし？"
        
        let json = getQuizJson()
        print(json.quiz[0].answer)
    }
    
    private func getQuizJson() -> QuizInfo {
        let path: String = Bundle.main.path(forResource: "Resource/quiz", ofType: "json")!
        var jsonData: QuizInfo!
        do {
            let content = try String(contentsOfFile: path)
            jsonData = try JSONDecoder().decode(QuizInfo.self, from: content.data(using: .utf8)!)
            return jsonData
        } catch  {
            // TODO: Error handling
            return jsonData
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.navigationController?.pushViewController(QuizViewController(), animated: true)
    }
}
