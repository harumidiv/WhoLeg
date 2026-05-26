//
//  TitleScreen.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import SwiftUI
import UIKit

struct TitleScreen: View {
    let imageName: String
    let answerText: String
    let onStart: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var buttonSize: CGFloat { horizontalSizeClass == .regular ? 250 : 160 }
    private var topPadding: CGFloat { horizontalSizeClass == .regular ? 80 : 40 }

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                circleImageView
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: horizontalSizeClass == .regular ? 580 : .infinity)
                    .padding(.horizontal, horizontalSizeClass == .regular ? 0 : 40)
                    .padding(.top, topPadding)

                Text(answerText)
                    .font(.system(size: 40))
                    .foregroundColor(Color("Text"))
                    .padding(.top, 16)

                Spacer()

                Button(action: onStart) {
                    Image("start")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: buttonSize, height: buttonSize)
                .padding(.bottom, 32)
            }
        }
    }

    private var circleImageView: some View {
        ZStack {
            Circle()
                .fill(Color(UIColor(appColor: .c1)))
            ZStack {
                Circle()
                    .fill(Color("Background"))
                Image(imageName)
                    .resizable()
                    .scaledToFit()
            }
            .clipShape(Circle())
            .padding(10)
        }
    }
}
