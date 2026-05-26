//
//  ResultWireframe.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/21.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

protocol ResultWireframe {
    func showTitle(vc: UIViewController)
    func showRetryQuiz(vc: UIViewController, data: QuizInfo)
}

class ResultWireframeImpl: ResultWireframe {
    func showTitle(vc: UIViewController) {
        vc.navigationController?.popToRootViewController(animated: true)
    }

    func showRetryQuiz(vc: UIViewController, data: QuizInfo) {
        guard let nav = vc.navigationController, let titleVC = nav.viewControllers.first else { return }
        let quizViewController = QuizViewController(quizData: data, score: 0, count: 1)
        quizViewController.injector(presenter: QuizPresenterImpl(model: QuizModelImpl(), output: quizViewController), wireframe: QuizWireframeImpl())
        nav.setViewControllers([titleVC, quizViewController], animated: true)
    }
}
