//
//  TitleModel.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import Foundation

protocol TitleModel {
    func getQuizJson() -> QuizInfo 
}

class TitleModelImpl: TitleModel {
    func getQuizJson() -> QuizInfo {
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
}
