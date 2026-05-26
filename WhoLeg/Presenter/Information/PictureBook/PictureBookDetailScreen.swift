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
                    .frame(maxWidth: .infinity)
                    .padding()
                Text(viewModel.text)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                Button(viewModel.text + "って何？") {
                    onDetailTapped()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
