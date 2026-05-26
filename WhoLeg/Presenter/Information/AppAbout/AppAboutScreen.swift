//
//  AppAboutScreen.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/24.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import SwiftUI

struct AppAboutScreen: View {
    let version: String

    var body: some View {
        VStack {
            Spacer()
            Text(
                """
                だれのあし
                バージョン : \(version)

                (C) Harumi Sagawa
                """
            )
            .font(.body)
            .multilineTextAlignment(.center)
            .padding()
            Spacer()
        }
    }
}
