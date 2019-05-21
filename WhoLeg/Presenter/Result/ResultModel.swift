//
//  ResultModel.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/21.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import Foundation

protocol ResultModel {
    func getJson() -> QuizInfo
}

class ResultModelImpl: ResultModel {
    let quizRepository: QuizRepository
    init(quizRepository: QuizRepository) {
        self.quizRepository = quizRepository
    }
    func getJson() -> QuizInfo {
        return quizRepository.getJsonData()
    }
}
