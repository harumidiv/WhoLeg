//
//  ResultScreen.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/05/26.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import SwiftUI

struct ResultScreen: View {
    let score: Int

    private struct Style {
        let background: Color
        let message: String
        let imageName: String
        let imageAlignment: Alignment
        let imageHeightRatio: CGFloat
    }

    private var style: Style {
        if score == 10 {
            return Style(
                background: Color(red: 1, green: 0.485, blue: 0.226),
                message: "全問正解!!",
                imageName: "white2",
                imageAlignment: .bottom,
                imageHeightRatio: 0.65
            )
        } else if score > 5 {
            return Style(
                background: .brand,
                message: "まずまずだね",
                imageName: "white",
                imageAlignment: .bottomLeading,
                imageHeightRatio: 0.75
            )
        } else {
            return Style(
                background: .brandNavy,
                message: "うーん...",
                imageName: "black",
                imageAlignment: .bottomTrailing,
                imageHeightRatio: 0.40
            )
        }
    }

    var body: some View {
        let style = style
        GeometryReader { geometry in
            ZStack(alignment: style.imageAlignment) {
                style.background
                    .ignoresSafeArea()

                Image(style.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: geometry.size.height * style.imageHeightRatio)
                    .padding(.horizontal, 16)
                    .accessibilityHidden(true)

                scoreHeader(message: style.message)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func scoreHeader(message: String) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 96, weight: .heavy, design: .rounded))
                Text("/ 10")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .opacity(0.8)
            }
            Text(message)
                .font(.system(size: 32, weight: .bold, design: .rounded))
        }
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Good") {
    ResultScreen(score: 10)
}

#Preview("Normal") {
    ResultScreen(score: 7)
}

#Preview("Bad") {
    ResultScreen(score: 3)
}
