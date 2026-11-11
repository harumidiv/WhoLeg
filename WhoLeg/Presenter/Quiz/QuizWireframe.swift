//
//  QuizWireframe.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/20.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

protocol QuizWireframe: AnyObject {
    func showNextQuiz(vc: UIViewController, data: QuizInfo, score: Int, count: Int, wrongQuizzes: [Quiz])
    func showResult(vc: UIViewController, score: Int, wrongQuizzes: [Quiz])
}

class QuizWireframeImpl: QuizWireframe {
    func showNextQuiz(vc: UIViewController, data: QuizInfo, score: Int, count: Int, wrongQuizzes: [Quiz]) {
        let quizViewController = QuizViewController(quizData: data, score: score, count: count, wrongQuizzes: wrongQuizzes)
        quizViewController.injector(presenter: QuizPresenterImpl(model: QuizModelImpl(), output: quizViewController), wireframe: QuizWireframeImpl())
        vc.navigationController?.pushViewController(quizViewController, animated: true)
    }

    func showResult(vc: UIViewController, score: Int, wrongQuizzes: [Quiz]) {
        let resultViewController = ResultViewController(score: score, wrongQuizzes: wrongQuizzes)
        resultViewController.injector(presenter: ResultPresenterImpl(model: ResultModelImpl(quizRepository: QuizRepositoryImpl())),
                                      wireframe: ResultWireframeImpl())
        vc.navigationController?.pushViewController(resultViewController, animated: true)
    }
}
