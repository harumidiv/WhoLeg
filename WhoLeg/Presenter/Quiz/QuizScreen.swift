//
//  QuizScreen.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/19.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import SwiftUI
import UIKit

final class QuizScreenState: ObservableObject {
    @Published var imageName: String = ""
    @Published var choices: [String] = []
    /// 回答後に正解ならtrue、不正解ならfalse。未回答はnil
    @Published var isCorrect: Bool? = nil
    @Published var isEnabled: Bool = true
    @Published var count: Int = 1
    let total: Int = 10
}

struct QuizScreen: View {
    @ObservedObject var state: QuizScreenState
    let onAnswer: (String) -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 16) {
                progressBar

                imageCard
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                optionButtons
            }
            .frame(maxWidth: horizontalSizeClass == .regular ? 640 : .infinity)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .navigationBarBackButtonHidden(true)
    }

    private var progressBar: some View {
        ProgressView(value: Double(state.count), total: Double(state.total))
            .tint(.brand)
            .scaleEffect(x: 1, y: 2, anchor: .center)
            .padding(.horizontal, 4)
    }

    private var imageCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)

            Image(state.imageName)
                .resizable()
                .scaledToFit()
                .padding(16)

            if let isCorrect = state.isCorrect {
                resultMark(isCorrect: isCorrect)
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: state.isCorrect)
    }

    private func resultMark(isCorrect: Bool) -> some View {
        Image(systemName: isCorrect ? "circle" : "xmark")
            .font(.system(size: 220, weight: .heavy))
            .foregroundStyle(isCorrect ? Color.brand : Color.brandNavy)
            .shadow(color: .white, radius: 2)
            .accessibilityLabel(isCorrect ? "せいかい" : "ふせいかい")
    }

    private var optionButtons: some View {
        VStack(spacing: 12) {
            ForEach(state.choices, id: \.self) { choice in
                Button {
                    onAnswer(choice)
                } label: {
                    Text(choice)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                }
                .buttonStyle(.chunky(color: .brandAccent, shadowColor: .brandAccentShadow))
                .disabled(!state.isEnabled)
            }
        }
    }
}

#Preview {
    let state = QuizScreenState()
    state.imageName = "kirin"
    state.choices = ["きりん", "しまうま", "ぞう", "じゆうのめがみ"]
    state.count = 3
    return QuizScreen(state: state, onAnswer: { _ in })
}
