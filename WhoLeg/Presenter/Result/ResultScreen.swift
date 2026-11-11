//
//  ResultScreen.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/05/26.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import SwiftUI

final class ResultScreenState: ObservableObject {
    /// 答えを表示済みのクイズのインデックス
    @Published var revealedIndices: Set<Int> = []
    /// リワード広告を表示できる状態ならtrue
    @Published var isAdReady: Bool = false
}

struct ResultScreen: View {
    let score: Int
    let wrongQuizzes: [Quiz]
    @ObservedObject var state: ResultScreenState
    /// 広告を見て答えを表示するボタンが押されたときに、そのクイズのインデックスを渡して呼ぶ
    let onReveal: (Int) -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var rowsHeight: CGFloat = 0

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

                VStack(spacing: 20) {
                    scoreHeader(message: style.message)
                    if !wrongQuizzes.isEmpty {
                        wrongQuizPanel(maxHeight: geometry.size.height * 0.55)
                            .frame(maxWidth: horizontalSizeClass == .regular ? 520 : .infinity)
                            .padding(.horizontal, 16)
                    }
                }
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

    private func wrongQuizPanel(maxHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("まちがえた もんだい")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(Color(.secondaryLabel))
                .padding(.horizontal, 4)

            // 少ないときは中身の高さに合わせ、多いときだけスクロールさせる
            ScrollView {
                wrongQuizRows
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { rowsHeight = $0 }
            }
            .scrollBounceBehavior(.basedOnSize)
            .frame(height: min(rowsHeight, maxHeight))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.95))
        )
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }

    private var wrongQuizRows: some View {
        VStack(spacing: 8) {
            ForEach(wrongQuizzes.indices, id: \.self) { index in
                wrongQuizRow(index: index)
            }
        }
    }

    private func wrongQuizRow(index: Int) -> some View {
        let quiz = wrongQuizzes[index]
        let isRevealed = state.revealedIndices.contains(index)
        let imageName = URL(fileURLWithPath: quiz.image).deletingPathExtension().lastPathComponent

        return HStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(4)
                .frame(width: 56, height: 56)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color(.separator), lineWidth: 1)
                )
                .accessibilityHidden(true)

            Text(isRevealed ? quiz.answer : "？？？")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(isRevealed ? Color("Text") : Color(.tertiaryLabel))
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Spacer(minLength: 8)

            if !isRevealed {
                Button {
                    onReveal(index)
                } label: {
                    Label(state.isAdReady ? "こたえを みる" : "じゅんびちゅう", systemImage: "play.rectangle.fill")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                }
                .buttonStyle(.chunky(color: .brand, shadowColor: Color(UIColor(hex: "#0B7A44"))))
                .disabled(!state.isAdReady)
                .opacity(state.isAdReady ? 1 : 0.5)
                .accessibilityHint("広告を見ると答えが表示されます")
            }
        }
        .accessibilityElement(children: .contain)
    }
}

private let previewQuizzes: [Quiz] = [
    Quiz(image: "kirin.png", answer: "きりん", url: "", choice: Choice(a: "きりん", b: "いぬ", c: "ねこ", d: "ぞう")),
    Quiz(image: "zou.png", answer: "ぞう", url: "", choice: Choice(a: "きりん", b: "いぬ", c: "ねこ", d: "ぞう")),
    Quiz(image: "simauma.png", answer: "しまうま", url: "", choice: Choice(a: "きりん", b: "いぬ", c: "しまうま", d: "ぞう"))
]

private func previewState(revealed: Set<Int> = [], isAdReady: Bool = true) -> ResultScreenState {
    let state = ResultScreenState()
    state.revealedIndices = revealed
    state.isAdReady = isAdReady
    return state
}

#Preview("Good") {
    ResultScreen(score: 10, wrongQuizzes: [], state: previewState(), onReveal: { _ in })
}

#Preview("Normal") {
    ResultScreen(score: 7, wrongQuizzes: previewQuizzes, state: previewState(revealed: [1]), onReveal: { _ in })
}

#Preview("Bad") {
    ResultScreen(
        score: 3,
        wrongQuizzes: Array(repeating: previewQuizzes, count: 3).flatMap { $0 },
        state: previewState(isAdReady: false),
        onReveal: { _ in }
    )
}
