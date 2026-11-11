//
//  ResultViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import Combine
import UIKit
import SwiftUI

class ResultViewController: UIHostingController<ResultScreen> {
    let score: Int
    let wrongQuizzes: [Quiz]

    private var presenter: ResultPresenter!
    private var wireframe: ResultWireframe!
    private let state = ResultScreenState()
    private var cancellables = Set<AnyCancellable>()

    init(score: Int, wrongQuizzes: [Quiz]) {
        self.score = score
        self.wrongQuizzes = wrongQuizzes
        super.init(rootView: ResultScreen(score: score, wrongQuizzes: wrongQuizzes, state: state, onReveal: { _ in }))
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

        rootView = ResultScreen(score: score, wrongQuizzes: wrongQuizzes, state: state, onReveal: { [weak self] index in
            self?.showRewardedAd(for: index)
        })

        let adManager = RewardedAdManager.shared
        adManager.$isReady
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isReady in self?.state.isAdReady = isReady }
            .store(in: &cancellables)
        if !wrongQuizzes.isEmpty {
            adManager.loadIfNeeded()
        }
    }

    /// リワード広告を最後まで見たら、選んだクイズ1問だけ答えを表示する（図鑑には登録しない）
    private func showRewardedAd(for index: Int) {
        RewardedAdManager.shared.show(from: self) { [weak self] in
            self?.state.revealedIndices.insert(index)
        }
    }

    @objc func returnStartScreen(_ sender: UIBarButtonItem) {
        wireframe.showTitle(vc: self)
    }

    @objc func retryQuiz(_ sender: UIBarButtonItem) {
        wireframe.showRetryQuiz(vc: self, data: presenter.getjson())
    }
}
