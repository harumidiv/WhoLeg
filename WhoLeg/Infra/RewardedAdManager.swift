//
//  RewardedAdManager.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/11/11.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import Combine
import GoogleMobileAds
import UIKit

/// 結果画面で、間違えたクイズの答えを見るために表示するリワード広告
@MainActor
final class RewardedAdManager: NSObject, ObservableObject {
    static let shared = RewardedAdManager()

    #if DEBUG
    // 開発中は本番広告を表示・タップしないようにGoogleのテスト用広告ユニットを使う
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"
    #else
    private let adUnitID = "ca-app-pub-8522231452310619/1285054590"
    #endif

    /// 表示できる広告を読み込み済みならtrue
    @Published private(set) var isReady = false

    private var isStarted = false
    private var isLoading = false
    private var rewardedAd: RewardedAd?
    private var didEarnReward = false
    private var onReward: (() -> Void)?

    /// 広告を読み込む。SDKの初期化後（ATTの許可ダイアログが終わってから）呼ぶ
    func start() {
        guard !isStarted else { return }
        isStarted = true
        load()
    }

    /// 広告を表示し、最後まで見て報酬を獲得した場合のみ広告を閉じた後にonRewardを呼ぶ
    func show(from viewController: UIViewController, onReward: @escaping () -> Void) {
        guard let rewardedAd else {
            load()
            return
        }
        didEarnReward = false
        self.onReward = onReward
        rewardedAd.present(from: viewController) { [weak self] in
            self?.didEarnReward = true
        }
    }

    /// 読み込みに失敗していた場合などに読み込み直す
    func loadIfNeeded() {
        guard isStarted, rewardedAd == nil else { return }
        load()
    }

    private func load() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                let ad = try await RewardedAd.load(with: adUnitID, request: Request())
                ad.fullScreenContentDelegate = self
                rewardedAd = ad
                isReady = true
            } catch {
                print("Failed to load rewarded ad: \(error.localizedDescription)")
            }
        }
    }

    private func finish() {
        rewardedAd = nil
        isReady = false
        if didEarnReward {
            onReward?()
        }
        onReward = nil
        didEarnReward = false
        // 次回に備えて読み込み直す
        load()
    }
}

extension RewardedAdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        finish()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Failed to present rewarded ad: \(error.localizedDescription)")
        finish()
    }
}
