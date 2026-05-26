//
//  QuizViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/19.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit
import SwiftUI

class QuizViewController: UIHostingController<QuizScreen> {

    private let state: QuizScreenState
    var quizData: QuizInfo
    private var presenter: QuizPresenter!
    private var wireframe: QuizWireframe!
    private var score: Int
    let count: Int
    lazy var rand = Int.random(in: 0 ..< quizData.quiz.count)

    // MARK: - Initializer

    init(quizData: QuizInfo, score: Int, count: Int) {
        self.quizData = quizData
        self.score = score
        self.count = count
        let state = QuizScreenState()
        self.state = state
        super.init(rootView: QuizScreen(state: state, onAnswer: { _ in }))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - MethodInjection

    func injector(presenter: QuizPresenter, wireframe: QuizWireframe) {
        self.presenter = presenter
        self.wireframe = wireframe
    }

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        state.imageName = URL(fileURLWithPath: quizData.quiz[rand].image)
            .deletingPathExtension().lastPathComponent

        rootView = QuizScreen(state: state, onAnswer: { [weak self] answer in
            guard let self, self.state.isEnabled else { return }
            self.state.isEnabled = false
            self.presenter.answerCheck(select: answer, answer: self.quizData.quiz[self.rand].answer)
        })

        presenter.createRandomElement(
            a: quizData.quiz[rand].choice.a,
            b: quizData.quiz[rand].choice.b,
            c: quizData.quiz[rand].choice.c,
            d: quizData.quiz[rand].choice.d
        )

        title = "\(count)/10"
        navigationItem.hidesBackButton = true
    }
}

// MARK: - QuizPresenterOutput

extension QuizViewController: QuizPresenterOutput {
    func showQuiz(choice: [String]) {
        state.choices = choice
    }

    func answerResult(answer: Bool) {
        if answer {
            presenter.saveCorrectAnswerData(key: quizData.quiz[rand].image)
            presenter.correctSoundPlay()
            score += 1
            state.resultSymbol = "⚪︎"
            state.resultColor = Color(UIColor(appColor: .c1))
        } else {
            presenter.mistakeSoundPlay()
            state.resultSymbol = "✖︎"
            state.resultColor = Color(UIColor(appColor: .c2))
        }

        quizData.quiz.remove(at: rand)

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
            guard let self else { return }
            if self.count >= 10 {
                self.wireframe.showResult(vc: self, score: self.score)
            } else {
                self.wireframe.showNextQuiz(vc: self, data: self.quizData, score: self.score, count: self.count + 1)
            }
        }
    }
}
