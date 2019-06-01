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
    let quizRepository: QuizRepository

    init(quizRepository: QuizRepository) {
        self.quizRepository = quizRepository
    }

    func getQuizJson() -> QuizInfo {
        return quizRepository.getJsonData()
    }
}
