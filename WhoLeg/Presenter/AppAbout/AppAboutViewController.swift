//
//  AppAboutViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/24.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

class AppAboutViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "このアプリについて"

        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        label.text =
            """
            だれのあし
            バージョン : \(version)
            
            (C) Harumi Sagawa
            """
    }
}
