//
//  ResultViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    let score: Int
    init(score: Int) {
        self.score = score
        super.init(nibName: String(describing: ResultViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        if score == 10 {
            self.view = ResultGoodView()
        } else if score > 5 {
            let view = ResultNormalView()
            view.label.text = "\(score)/10\nまずまずだね"
            self.view = view
        } else {
            let view = ResultBadView()
            view.label.text = "\(score)/10\nうーん..."
            self.view = view
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "スコア"
        self.navigationItem.hidesBackButton = true
        
        let returnButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(returnStartScreen(_:)))
        navigationItem.leftBarButtonItem = returnButton
        
        let retryButton: UIBarButtonItem = UIBarButtonItem(title: "リトライ", style: .plain, target: self, action: #selector(returnStartScreen(_:)))
        navigationItem.rightBarButtonItem = retryButton
    }
    @objc func returnStartScreen(_ sender: UIBarButtonItem){
        print("tapped")
    }
    @objc func retryQuiz(_ sender: UIBarButtonItem) {
        
        //self.navigationController?.pushViewController(QuizViewController(quizData: QuizInfo(), score: 0, count: 1), animated: true)
    }
}
