//
//  SnapShotTest.swift
//  WhoLegTests
//
//  Created by しじみ100% on 2019/09/26.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import FBSnapshotTestCase
@testable import WhoLegTests

class SnapShotTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func testView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        view.backgroundColor = .green
        FBSnapshotVerifyView(view)
    }
}
