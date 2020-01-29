//
//  Springboard.swift
//  WhoLegUITests
//
//  Created by 佐川 晴海 on 2020/01/29.
//  Copyright © 2020 佐川晴海. All rights reserved.
//

import Foundation

import XCTest

final class Springboard {
    static let appDisplayName = "だれのあし"

    static let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    static let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")

    static func deleteMyApp() {
        XCUIApplication().terminate()
        springboard.activate()
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        sleep(2)

        let icon = springboard.otherElements["Home screen icons"].scrollViews.otherElements.icons[self.appDisplayName]
        if icon.exists {
            let iconFrame = icon.frame
            let springboardFrame = springboard.frame
            icon.press(forDuration: 2.5)

            springboard.coordinate(withNormalizedOffset: CGVector(dx: (iconFrame.minX + 9) / springboardFrame.maxX, dy: (iconFrame.minY + 9) / springboardFrame.maxY)).tap()

            Thread.sleep(forTimeInterval: 1.5)

            let languages = NSLocale.preferredLanguages
            let language = languages[0].prefix(2)
            if language == "ja" {
                springboard.buttons["削除"].firstMatch.tap()
            } else {
                springboard.buttons["Delete"].firstMatch.tap()
            }
            Thread.sleep(forTimeInterval: 0.5)
            XCUIDevice.shared.press(.home)
        }
    }

    private static func isSimulator() -> Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}
