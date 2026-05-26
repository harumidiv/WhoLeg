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

    var body: some View {
        List {
            Section {
                ForEach(items) { item in
                    Button {
                        guard item.isUnlocked else { return }
                        onSelect(item)
                    } label: {
                        HStack(spacing: 12) {
                            Image(item.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            Text(item.isUnlocked ? item.answer : "? ? ?")
                                .foregroundColor(.primary)
                            Spacer()
                            if item.isUnlocked {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption.weight(.semibold))
                            }
                        }
                        .frame(height: 50)
                    }
                }
            } header: {
                Text("正解した問題は名前が表示されます。 図鑑を完成を目指しましょう!!")
                    .font(.caption)
                    .textCase(nil)
            }
        }
        .listStyle(.plain)
    }
}
