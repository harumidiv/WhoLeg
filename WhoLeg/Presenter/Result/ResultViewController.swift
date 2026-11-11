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
        super.init(rootView: ResultScreen(score: score, wrongQuizzes: wrongQuizzes, legImageNames: [], state: state, onUnlock: { _ in }))
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

        // まわりに出す足は、全問の中からランダムに選ぶ
        let legImageNames = presenter.getjson().quiz
            .map { URL(fileURLWithPath: $0.image).deletingPathExtension().lastPathComponent }
            .shuffled()
            .prefix(ResultScreen.legCount)

        rootView = ResultScreen(score: score, wrongQuizzes: wrongQuizzes, legImageNames: Array(legImageNames), state: state, onUnlock: { [weak self] index in
            self?.showRewardedAd(for: index)
        }, onBack: { [weak self] in
            self?.returnStartScreen()
        }, onRetry: { [weak self] in
            self?.retryQuiz()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // もどる・リトライは画面の真ん中に出すので、足に隠れるナビゲーションバーは消す
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    /// リワード広告を最後まで見たら、選んだクイズ1問だけスクラッチを削れるようにする（図鑑には登録しない）
    private func showRewardedAd(for index: Int) {
        RewardedAdManager.shared.show(from: self) { [weak self] in
            self?.state.unlockedIndices.insert(index)
        }
    }

    private func returnStartScreen() {
        wireframe.showTitle(vc: self)
    }

    private func retryQuiz() {
        wireframe.showRetryQuiz(vc: self, data: presenter.getjson())
    }
}
