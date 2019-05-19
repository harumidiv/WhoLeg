//
//  QuizPresenter.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/19.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import Foundation

protocol QuizPresenter {
    func answerCheck(select: String, answer: String)
}

protocol QuizPresenterOutput: class {
    func answerResult(answer: Bool)
}

class QuizPresenterImpl: QuizPresenter {
    private weak var output: QuizPresenterOutput?
    private var model: QuizModel
    
    init(model: QuizModel, output: QuizPresenterOutput) {
        self.output = output
        self.model = model
    }
    
    func answerCheck(select: String, answer: String) {
        let result = model.stringComParison(lhs: select, rhs: answer)
        output?.answerResult(answer: result)
    }
}
