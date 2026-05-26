//
//  AppAboutViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/24.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit
import SwiftUI

class AppAboutViewController: UIHostingController<AppAboutScreen> {
    init() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        super.init(rootView: AppAboutScreen(version: version))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "このアプリについて"
    }
}
