//
//  InformationScreen.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/24.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import SwiftUI

struct InformationScreen: View {
    let onSelectPictureBook: () -> Void
    let onSelectAppAbout: () -> Void
    let onSelectRelatedApp: () -> Void

    var body: some View {
        List {
            Section("せつめい") {
                Button(action: onSelectPictureBook) {
                    HStack {
                        Text("ずかん")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                Button(action: onSelectAppAbout) {
                    HStack {
                        Text("このアプリについて")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
            }
            Section("その他") {
                Button(action: onSelectRelatedApp) {
                    HStack {
                        Text("関連アプリ")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
        .listStyle(.grouped)
    }
}
