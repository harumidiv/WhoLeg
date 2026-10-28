//
//  InterstitialAdManager.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/10/28.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import GoogleMobileAds
import UIKit

/// クイズを解き終えて結果画面へ移るときに表示するインタースティシャル広告
@MainActor
final class InterstitialAdManager: NSObject {
    static let shared = InterstitialAdManager()

    #if DEBUG
    // 開発中は本番広告を表示・タップしないようにGoogleのテスト用広告ユニットを使う
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910"
    #else
    private let adUnitID = "ca-app-pub-8522231452310619/2766186488"
    #endif

    /// 何プレイごとに広告を表示するか
    private let playInterval = 2

    private var isStarted = false
    private var playsSinceLastAd = 0
    private var interstitialAd: InterstitialAd?
    private var onDismiss: (() -> Void)?

    /// SDKを初期化して広告を読み込む。ATTの許可ダイアログが終わってから呼ぶ
    func start() {
        guard !isStarted else { return }
        isStarted = true
        MobileAds.shared.start()
        load()
    }

    /// 1プレイ終わるごとに呼ぶ。表示する回なら広告を出し、閉じた後にcompletionを呼ぶ
    func showIfNeeded(from viewController: UIViewController, completion: @escaping () -> Void) {
        playsSinceLastAd += 1
        guard playsSinceLastAd >= playInterval, let interstitialAd else {
            completion()
            return
        }
        playsSinceLastAd = 0
        onDismiss = completion
        interstitialAd.present(from: viewController)
    }

    private func load() {
        Task {
            do {
                let ad = try await InterstitialAd.load(with: adUnitID, request: Request())
                ad.fullScreenContentDelegate = self
                interstitialAd = ad
            } catch {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
            }
        }
    }

    private func finish() {
        interstitialAd = nil
        onDismiss?()
        onDismiss = nil
        // 次回に備えて読み込み直す
        load()
    }
}

extension InterstitialAdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        finish()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Failed to present interstitial ad: \(error.localizedDescription)")
        finish()
    }
}
