//
//  InformationScreen.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/24.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import SwiftUI

struct InformationScreen: View {
    let collectedCount: Int
    let totalCount: Int
    let onSelectPictureBook: () -> Void
    let onSelectAppAbout: () -> Void
    let onSelectRelatedApp: () -> Void

    var body: some View {
        List {
            Section("せつめい") {
                row(title: "ずかん", systemImage: "book.closed.fill", color: .brand, action: onSelectPictureBook) {
                    Text("\(collectedCount) / \(totalCount)")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))
                        .monospacedDigit()
                }
                row(title: "このアプリについて", systemImage: "info", color: .brandNavy, action: onSelectAppAbout)
            }
            Section("その他") {
                row(title: "関連アプリ", systemImage: "square.grid.2x2.fill", color: .brandAccent, action: onSelectRelatedApp)
            }
        }
        .listStyle(.insetGrouped)
    }

    private func row(
        title: String,
        systemImage: String,
        color: Color,
        action: @escaping () -> Void,
        @ViewBuilder trailing: () -> some View = { EmptyView() }
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(color, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text(title)
                    .foregroundStyle(Color(.label))
                Spacer()
                trailing()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
        }
    }
}

#Preview {
    InformationScreen(
        collectedCount: 6,
        totalCount: 50,
        onSelectPictureBook: {},
        onSelectAppAbout: {},
        onSelectRelatedApp: {}
    )
}
