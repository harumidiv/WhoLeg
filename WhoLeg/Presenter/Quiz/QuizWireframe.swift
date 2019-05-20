//
//  QuizWireframe.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/20.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

protocol QuizWireframe: class {
    func showNextQuiz(vc: UIViewController, data: QuizInfo, score: Int)
    func showResult(vc: UIViewController, score: Int)
}

class QuizWireframeImpl: QuizWireframe {
    func showNextQuiz(vc: UIViewController, data: QuizInfo, score: Int) {
        
        let quizViewController = QuizViewController(quizData: data, score: score)
        quizViewController.injector(presenter: QuizPresenterImpl(model: QuizModelImpl(), output: quizViewController), wireframe: QuizWireframeImpl())
        vc.navigationController?.pushViewController(quizViewController, animated: true)
    }
    
    func showResult(vc: UIViewController, score: Int) {
        vc.navigationController?.pushViewController(ResultViewController(score: score), animated: true)
    }
}
