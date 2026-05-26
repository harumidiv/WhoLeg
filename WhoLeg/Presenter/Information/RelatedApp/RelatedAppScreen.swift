//
//  RelatedAppScreen.swift
//  WhoLeg
//
//  Created by 佐川 晴海 on 2020/05/23.
//  Copyright © 2020 佐川晴海. All rights reserved.
//

import SwiftUI
import UIKit

struct RelatedAppScreen: View {
    struct AppSection: Identifiable {
        let id = UUID()
        let name: String
        let items: [AppItem]
    }

    struct AppItem: Identifiable {
        let id = UUID()
        let image: UIImage
        let title: String
        let description: String
        let appID: String
    }

    let sections: [AppSection]
    let onDownload: (String) -> Void

    var body: some View {
        List {
            ForEach(sections) { section in
                Section(section.name) {
                    ForEach(section.items) { item in
                        HStack(spacing: 12) {
                            Image(uiImage: item.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Button("DL") {
                                onDownload(item.appID)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.grouped)
    }
}
