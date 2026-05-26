//
//  TitleViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit
import SwiftUI

class TitleViewController: UIHostingController<TitleScreen> {

    private var presenter: TitlePresenter!
    private var jsonData: QuizInfo!

    init() {
        super.init(rootView: TitleScreen(imageName: "", answerText: "", onStart: {}))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func injector(presenter: TitlePresenter) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        jsonData = presenter.getJsonData()
        let rand = Int.random(in: 0 ..< jsonData.quiz.count)
        let quiz = jsonData.quiz[rand]
        let imageName = URL(fileURLWithPath: quiz.image).deletingPathExtension().lastPathComponent

        rootView = TitleScreen(
            imageName: imageName,
            answerText: quiz.answer,
            onStart: { [weak self] in self?.quizStart() }
        )

        title = "だれのあし？"
        navigationItem.hidesBackButton = true
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "information"),
            style: .plain,
            target: self,
            action: #selector(showInformation)
        )
    }

    @objc private func showInformation() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.pushViewController(InformationViewController(data: jsonData), animated: true)
    }

    private func quizStart() {
        let quizViewController = QuizViewController(quizData: jsonData, score: 0, count: 1)
        quizViewController.injector(
            presenter: QuizPresenterImpl(model: QuizModelImpl(), output: quizViewController),
            wireframe: QuizWireframeImpl()
        )
        navigationController?.pushViewController(quizViewController, animated: true)
    }
}
