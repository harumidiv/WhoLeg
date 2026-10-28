//
//  SceneDelegate.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/10/28.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

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
}
