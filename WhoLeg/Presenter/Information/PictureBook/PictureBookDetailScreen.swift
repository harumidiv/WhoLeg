//
//  PictureBookDetailScreen.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/10/13.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import SwiftUI

struct PictureBookDetailScreen: View {
    struct ViewModel {
        let imageName: String  // without .png extension
        let text: String
        let url: URL
    }

    let viewModel: ViewModel
    let onDetailTapped: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(viewModel.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 420)
                    .padding(24)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))

                Text(viewModel.text)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)

                Button(action: onDetailTapped) {
                    Label(viewModel.text + "って何？", systemImage: "safari")
                        .font(.system(.headline, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(.brand)
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BannerAdView()
                .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    PictureBookDetailScreen(
        viewModel: .init(imageName: "kirin", text: "きりん", url: URL(string: "https://example.com")!),
        onDetailTapped: {}
    )
}
