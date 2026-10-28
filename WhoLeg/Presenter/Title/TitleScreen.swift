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

    private var isRegular: Bool { horizontalSizeClass == .regular }

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 16)

                circleImageView
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: isRegular ? 520 : .infinity)
                    .padding(.horizontal, isRegular ? 0 : 40)

                VStack(spacing: 4) {
                    Text("これは だれの あし？")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text(answerText)
                        .font(.system(size: isRegular ? 48 : 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color("Text"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)

                Spacer(minLength: 24)

                startButton
                    .frame(maxWidth: isRegular ? 420 : .infinity)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
            }
        }
    }

    private var circleImageView: some View {
        ZStack {
            Circle()
                .fill(Color.brand)
            Circle()
                .fill(Color.white)
                .padding(8)
            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(24)
                .clipShape(Circle())
        }
        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
    }

    private var startButton: some View {
        Button(action: onStart) {
            Label("スタート", systemImage: "play.fill")
                .font(.system(size: isRegular ? 32 : 26, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: isRegular ? 80 : 64)
        }
        .buttonStyle(.chunky(color: .brand, shadowColor: Color(UIColor(hex: "#0B7A44"))))
    }
}

/// 押し込むと沈む、立体感のあるカプセルボタン
struct ChunkyButtonStyle: ButtonStyle {
    let color: Color
    let shadowColor: Color

    private let depth: CGFloat = 6

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        configuration.label
            .foregroundStyle(.white)
            .background(Capsule().fill(color))
            .offset(y: pressed ? depth : 0)
            .background(Capsule().fill(shadowColor).offset(y: depth))
            .padding(.bottom, depth)
            .animation(.easeOut(duration: 0.08), value: pressed)
    }
}

extension ButtonStyle where Self == ChunkyButtonStyle {
    static func chunky(color: Color, shadowColor: Color) -> ChunkyButtonStyle {
        ChunkyButtonStyle(color: color, shadowColor: shadowColor)
    }
}

#Preview {
    TitleScreen(imageName: "kirin", answerText: "きりん", onStart: {})
}
