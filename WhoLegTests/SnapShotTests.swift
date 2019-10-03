//
//  SnapShotTest.swift
//  WhoLegTests
//
//  Created by しじみ100% on 2019/09/26.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import FBSnapshotTestCase
@testable import WhoLeg

class SnapShotTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        recordMode = true
    }

    func testInformationScreen() {
        let vc = TitleViewController()
        let presenter = TitlePresenterImpl(model: TitleModelImpl(quizRepository: QuizRepositoryImpl()))
        vc.injector(presenter: presenter)

        let nc = UINavigationController(rootViewController: vc)
        let window = UIWindow(frame: nc.view.frame)
        window.addSubview(nc.view)
        // TODO: 画像とテキストのdiffを無視してテストを通るようにする
//        FBSnapshotVerifyView(nc.view)
    }
}
