//
//  TitleViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {

    private var presenter: TitlePresenter!
    
    var jsonData: QuizInfo!
    
    func injector(presenter: TitlePresenter){
        self.presenter = presenter
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "だれのあし？"
        
        jsonData = presenter.getJsonData()
    }

    
    // MAKR: - Event
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let quizViewController = QuizViewController(quizData: jsonData, score: 0)
        quizViewController.injector(presenter: QuizPresenterImpl(model: QuizModelImpl(), output: quizViewController), wireframe: QuizWireframeImpl())
        self.navigationController?.pushViewController(quizViewController, animated: true)
        
    }
}
