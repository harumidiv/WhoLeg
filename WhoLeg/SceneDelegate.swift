//
//  SceneDelegate.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/10/28.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import AppTrackingTransparency
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let titleViewController = TitleViewController()
        titleViewController.injector(presenter: TitlePresenterImpl(model: TitleModelImpl(quizRepository: QuizRepositoryImpl())))

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: titleViewController)
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // アプリがアクティブな状態でないとATTダイアログが表示されないため、ここで許可を求める。
        // 直後はまだバックグラウンド扱いでリクエストが無視されるので、次のメインループまで遅らせる
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            InterstitialAdManager.shared.start()
            return
        }
        DispatchQueue.main.async {
            ATTrackingManager.requestTrackingAuthorization { _ in
                // ユーザーの選択が反映されるように、ダイアログを閉じてから広告SDKを開始する
                DispatchQueue.main.async {
                    InterstitialAdManager.shared.start()
                }
            }
        }
    }
}
