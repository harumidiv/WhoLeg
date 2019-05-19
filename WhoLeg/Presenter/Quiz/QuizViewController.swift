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
    @IBOutlet weak var optionA: QuizOptionButton! {
        didSet {
            optionA.addTarget(self, action: #selector(tapAnswer(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet weak var optionB: QuizOptionButton!{
        didSet {
            optionB.addTarget(self, action: #selector(tapAnswer(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet weak var optionC: QuizOptionButton!{
        didSet {
            optionC.addTarget(self, action: #selector(tapAnswer(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet weak var optionD: QuizOptionButton!{
        didSet {
            optionD.addTarget(self, action: #selector(tapAnswer(_:)), for: .touchUpInside)
        }
    }
    
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
    
    // MARK: - Event
    
    @objc func tapAnswer(_ sender: UIButton){
        if quizData.quiz[0].answer == sender.titleLabel?.text {
            print("正解")
        } else {
            print("不正解")
        }
    }
}
