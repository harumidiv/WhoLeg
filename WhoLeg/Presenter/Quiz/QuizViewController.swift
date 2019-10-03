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

    @IBOutlet weak var optionB: QuizOptionButton! {
        didSet {
            optionB.addTarget(self, action: #selector(tapAnswer(_:)), for: .touchUpInside)
        }
    }

    @IBOutlet weak var optionC: QuizOptionButton! {
        didSet {
            optionC.addTarget(self, action: #selector(tapAnswer(_:)), for: .touchUpInside)
        }
    }

    @IBOutlet weak var optionD: QuizOptionButton! {
        didSet {
            optionD.addTarget(self, action: #selector(tapAnswer(_:)), for: .touchUpInside)
        }
    }

    @IBOutlet weak var resultLabel: UILabel! {
        didSet {
            resultLabel.text = ""
        }
    }

    lazy var rand = Int.random(in: 0 ..< quizData.quiz.count)
    var quizData: QuizInfo
    private var presenter: QuizPresenter!
    private var wireframe: QuizWireframe!
    var score: Int
    let count: Int
    var isBeforeAnswer = true

    // MARK: - Initializer

    init(quizData: QuizInfo, score: Int, count: Int) {
        self.quizData = quizData
        self.score = score
        self.count = count
        super.init(nibName: String(describing: QuizViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
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
        navigationItem.hidesBackButton = true
        title = "\(count)/10"

        let srcImage = UIImage(named: quizData.quiz[rand].image)!
        UIGraphicsBeginImageContextWithOptions(srcImage.size, true, 0.0)
        srcImage.draw(in: CGRect(origin: CGPoint.zero, size: srcImage.size))
        let remakedImage = UIGraphicsGetImageFromCurrentImageContext()!
        image.image = createMaskImage(image: remakedImage)
        UIGraphicsEndImageContext()

        presenter.createRandomElement(a: quizData.quiz[rand].choice.a,
                                      b: quizData.quiz[rand].choice.b,
                                      c: quizData.quiz[rand].choice.c,
                                      d: quizData.quiz[rand].choice.d)
    }

    // MARK: - Event

    @objc func tapAnswer(_ sender: UIButton) {
        if isBeforeAnswer {
            presenter.answerCheck(select: sender.titleLabel!.text!, answer: quizData.quiz[rand].answer)
            isBeforeAnswer = false
        }
    }

    // MARK: - PrivateMethod

    private func createMaskImage(image: UIImage) -> UIImage {
        let cgImage = image.cgImage

        let maskColor: [CGFloat] = [255, 255, 255, 255, 255, 255]
        let maskedImage = cgImage?.copy(maskingColorComponents: maskColor)

        return UIImage(cgImage: maskedImage!)
    }
}

extension QuizViewController: QuizPresenterOutput {
    func showQuiz(choice: [String]) {
        optionA.setTitle(choice[0], for: .normal)
        optionB.setTitle(choice[1], for: .normal)
        optionC.setTitle(choice[2], for: .normal)
        optionD.setTitle(choice[3], for: .normal)
    }

    func answerResult(answer: Bool) {
        if answer {
            presenter.saveCorrectAnswerData(key: quizData.quiz[rand].image)
            presenter.correctSoundPlay()
            score += 1
            resultLabel.text = "⚪︎"
            resultLabel.textColor = UIColor(appColor: .c1)
            optionA.isEnabled = false
            optionB.isEnabled = false
            optionC.isEnabled = false
            optionD.isEnabled = false
        } else {
            presenter.mistakeSoundPlay()
            resultLabel.text = "✖︎"
            resultLabel.textColor = UIColor(appColor: .c2)
            optionA.isEnabled = false
            optionB.isEnabled = false
            optionC.isEnabled = false
            optionD.isEnabled = false
        }

        // quizデータの削除
        quizData.quiz.remove(at: rand)

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            if self.count >= 10 {
                self.wireframe.showResult(vc: self, score: self.score)
            } else {
                self.wireframe.showNextQuiz(vc: self, data: self.quizData, score: self.score, count: self.count + 1)
            }
        }
    }
}
