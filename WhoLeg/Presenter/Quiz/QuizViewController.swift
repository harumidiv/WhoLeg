//
//  QuizViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/19.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var optionA: QuizOptionButton!
    @IBOutlet weak var optionB: QuizOptionButton!
    @IBOutlet weak var optionC: QuizOptionButton!
    @IBOutlet weak var optionD: QuizOptionButton!
    
    var quizData: QuizInfo
    
    // MARK: - Initializer
    init(quizData: QuizInfo) {
        self.quizData = quizData
        super.init(nibName: String(describing: QuizViewController.self), bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        optionA.setTitle(quizData.quiz[0].choice.a, for: .normal)
        optionB.setTitle(quizData.quiz[0].choice.b, for: .normal)
        optionC.setTitle(quizData.quiz[0].choice.c, for: .normal)
        optionD.setTitle(quizData.quiz[0].choice.d, for: .normal)
        image.image = UIImage(named: quizData.quiz[0].image)
        
    }
}
