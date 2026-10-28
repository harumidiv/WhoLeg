//
//  ResultViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit
import SwiftUI

class ResultViewController: UIHostingController<ResultScreen> {
    let score: Int

    private var presenter: ResultPresenter!
    private var wireframe: ResultWireframe!

    init(score: Int) {
        self.score = score
        super.init(rootView: ResultScreen(score: score))
    }

    func injector(presenter: ResultPresenter, wireframe: ResultWireframe) {
        self.presenter = presenter
        self.wireframe = wireframe
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "スコア"
        navigationItem.hidesBackButton = true

        // 色付き背景の上でタイトルとボタンを読めるように白にする
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = UINavigationBar.appearance().titleTextAttributes ?? [:]
        appearance.titleTextAttributes[.foregroundColor] = UIColor.white
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance

        let returnButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(returnStartScreen(_:)))
        navigationItem.leftBarButtonItem = returnButton

        let retryButton = UIBarButtonItem(title: "リトライ", style: .plain, target: self, action: #selector(retryQuiz(_:)))
        navigationItem.rightBarButtonItem = retryButton
    }

    @objc func returnStartScreen(_ sender: UIBarButtonItem) {
        wireframe.showTitle(vc: self)
    }

    @objc func retryQuiz(_ sender: UIBarButtonItem) {
        wireframe.showRetryQuiz(vc: self, data: presenter.getjson())
    }
}
