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
    func createRandomElement(a: String, b: String, c: String, d: String)
    func saveCorrectAnswerData(key: String)
    func correctSoundPlay()
    func mistakeSoundPlay()
}

protocol QuizPresenterOutput: class {
    func answerResult(answer: Bool)
    func showQuiz(choice: [String])
}

class QuizPresenterImpl: QuizPresenter {
    private weak var output: QuizPresenterOutput?
    private var model: QuizModel

    // MARK: - Initializer

    init(model: QuizModel, output: QuizPresenterOutput) {
        self.output = output
        self.model = model
    }

    func correctSoundPlay() {
        model.correctSoundPlay()
    }

    func mistakeSoundPlay() {
        model.mistakeSoundPlay()
    }

    func saveCorrectAnswerData(key: String) {
        model.saveCorrectAnswerData(key: key)
    }

    func createRandomElement(a: String, b: String, c: String, d: String) {
        let element = model.createRandomElement(a: a, b: b, c: c, d: d)
        output?.showQuiz(choice: element)
    }

    func answerCheck(select: String, answer: String) {
        let result = model.stringComParison(lhs: select, rhs: answer)
        output?.answerResult(answer: result)
    }
}
