//
//  AppDelegate.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().tintColor = UIColor(appColor: .c1)
        let titleFont = UIFont.systemFont(ofSize: 17, weight: .bold)
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont(descriptor: titleFont.fontDescriptor.withDesign(.rounded) ?? titleFont.fontDescriptor, size: 17)
        ]
        return true
    }
}
