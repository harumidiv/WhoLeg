//
//  PictureBookScreen.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/24.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import SwiftUI
import UIKit

struct PictureBookScreen: View {
    struct Item: Identifiable {
        let id: Int          // index in quiz array
        let imageName: String // without .png extension
        let answer: String
        let isUnlocked: Bool
    }

    let items: [Item]
    let onSelect: (Item) -> Void

    private let columns = [GridItem(.adaptive(minimum: 104), spacing: 12)]

    private var unlockedCount: Int { items.filter(\.isUnlocked).count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(items) { item in
                        Button {
                            onSelect(item)
                        } label: {
                            cell(item)
                        }
                        .buttonStyle(.plain)
                        .disabled(!item.isUnlocked)
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("あつめた かず")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(unlockedCount) / \(items.count)")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .monospacedDigit()
            }
            ProgressView(value: Double(unlockedCount), total: Double(max(items.count, 1)))
                .tint(.brand)
            Text("正解した問題は名前が表示されます。図鑑の完成を目指しましょう!!")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func cell(_ item: Item) -> some View {
        VStack(spacing: 6) {
            Image(item.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 72)
                .frame(maxWidth: .infinity)
                .padding(6)
                .opacity(item.isUnlocked ? 1 : 0.35)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    if !item.isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.gray)
                            .padding(6)
                    }
                }
            Text(item.isUnlocked ? item.answer : "？？？")
                .font(.system(.footnote, design: .rounded, weight: .bold))
                .foregroundStyle(item.isUnlocked ? .primary : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(8)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            if item.isUnlocked {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.brand.opacity(0.5), lineWidth: 1.5)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PictureBookScreen(
        items: [
            .init(id: 0, imageName: "kirin", answer: "きりん", isUnlocked: true),
            .init(id: 1, imageName: "neko", answer: "ねこ", isUnlocked: false),
            .init(id: 2, imageName: "kaba", answer: "かば", isUnlocked: true)
        ],
        onSelect: { _ in }
    )
}
