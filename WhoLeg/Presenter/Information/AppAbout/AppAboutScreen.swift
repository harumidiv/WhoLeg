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
        VStack(spacing: 16) {
            Spacer()

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 27, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
                .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text("だれのあし")
                    .font(.system(.title, design: .rounded, weight: .bold))
                Text("バージョン \(version)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Spacer()

            Text("(C) Harumi Sagawa")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    AppAboutScreen(version: "2.4.0")
}
