//
//  ResultScreen.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/05/26.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import SwiftUI

final class ResultScreenState: ObservableObject {
    /// 広告を見て、スクラッチを削れるようになったクイズのインデックス
    @Published var unlockedIndices: Set<Int> = []
    /// スクラッチを削り終えて答えを表示済みのクイズのインデックス
    @Published var revealedIndices: Set<Int> = []
    /// リワード広告を表示できる状態ならtrue
    @Published var isAdReady: Bool = false
}

struct ResultScreen: View {
    let score: Int
    let wrongQuizzes: [Quiz]
    /// 画面のまわりから飛び出させる足の画像名（拡張子なし）
    let legImageNames: [String]
    @ObservedObject var state: ResultScreenState
    /// 広告を見てスクラッチを削れるようにするボタンが押されたときに、そのクイズのインデックスを渡して呼ぶ
    let onUnlock: (Int) -> Void
    /// タイトルにもどる
    var onBack: () -> Void = {}
    /// もう一度クイズをする
    var onRetry: () -> Void = {}

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var rowsHeight: CGFloat = 0
    @State private var preparedLegImages: [String: UIImage] = [:]
    @State private var isLegsStarted = false

    private struct Style {
        let background: Color
        let message: String
    }

    private var style: Style {
        if score == 10 {
            return Style(
                background: Color(red: 1, green: 0.485, blue: 0.226),
                message: String(localized: "全問正解!!")
            )
        } else if score > 5 {
            return Style(
                background: .brand,
                message: String(localized: "まずまずだね")
            )
        } else {
            return Style(
                background: .brandNavy,
                message: String(localized: "うーん...")
            )
        }
    }

    var body: some View {
        let style = style
        GeometryReader { geometry in
            ZStack {
                style.background
                    .ignoresSafeArea()

                LegBurstView(
                    imageNames: legImageNames,
                    slots: LegSlot.result,
                    isStarted: isLegsStarted,
                    appearanceOrder: LegSlot.resultOrder,
                    preparedImages: preparedLegImages
                )
                .ignoresSafeArea()

                // 足に囲まれた中にスコアと間違えた問題、もどる・リトライのボタンを出す。
                // ボタンは画面のはしに置くと足に隠れて見にくいので、真ん中にまとめる。
                // 間違えた問題があるときは一覧の場所を広く取れるよう上寄せにする
                let hasWrongQuizzes = !wrongQuizzes.isEmpty
                VStack(spacing: 16) {
                    scoreHeader(message: style.message)
                    if hasWrongQuizzes {
                        wrongQuizPanel(maxHeight: geometry.size.height * 0.44)
                    }
                    actionButtons
                        .padding(.top, 4)
                }
                .frame(maxWidth: horizontalSizeClass == .regular ? 520 : .infinity)
                .padding(.horizontal, 28)
                .padding(.top, hasWrongQuizzes ? geometry.size.height * 0.05 : 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: hasWrongQuizzes ? .top : .center)

                // 全問正解のお祝いに紙吹雪を降らせる
                if score == 10 {
                    ConfettiView()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task(id: legImageNames) {
            guard !legImageNames.isEmpty else { return }
            // 足は画面の短い辺の4割ほどなので、3倍の解像度でも足りる大きさに縮めておく
            preparedLegImages = await LegBurstView.prepareImages(named: legImageNames, maxPixelSize: 540)
            isLegsStarted = true
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Label("もどる", systemImage: "arrow.uturn.backward")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    // 言語によっては文字が長くなるので、収まらなければ小さくする
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(.chunky(color: Color(UIColor(hex: "#2B3240")), shadowColor: Color(UIColor(hex: "#161A22"))))
            .accessibilityLabel("タイトルに もどる")

            Button(action: onRetry) {
                Label("リトライ", systemImage: "arrow.clockwise")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    // 言語によっては文字が長くなるので、収まらなければ小さくする
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            // どの背景色（オレンジ・緑・紺）の上でも目立つよう白いボタンにする
            .buttonStyle(.chunky(
                color: .white,
                shadowColor: Color(UIColor(hex: "#C9CED6")),
                foregroundColor: Color(UIColor(hex: "#0B7A44"))
            ))
            .accessibilityLabel("もう いちど あそぶ")
        }
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
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .foregroundStyle(.white)
        // 後ろの足に重なっても読めるように影を濃くする
        .shadow(color: .black.opacity(0.35), radius: 6, y: 2)
        .accessibilityElement(children: .combine)
    }

    private func wrongQuizPanel(maxHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("けずって こたえあわせ")
                .font(.system(.headline, design: .rounded, weight: .heavy))
                .foregroundStyle(Color(UIColor(hex: "#1F2430")))
                .padding(.horizontal, 4)

            // 少ないときは中身の高さに合わせ、多いときだけスクロールさせる
            ScrollView {
                wrongQuizRows
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { rowsHeight = $0 }
            }
            .scrollBounceBehavior(.basedOnSize)
            .frame(height: min(rowsHeight, maxHeight))
        }
        .padding(14)
        // ダークモードでも黒くならないよう、パネルはいつも白にする
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .environment(\.colorScheme, .light)
        .shadow(color: .black.opacity(0.3), radius: 14, y: 6)
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
        let imageName = URL(fileURLWithPath: quiz.image).deletingPathExtension().lastPathComponent

        return HStack(spacing: 12) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(4)
                .frame(width: 60, height: 60)
                .background(Color(UIColor(hex: "#F3F5F8")), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .accessibilityLabel("\(index + 1)もんめの あし")

            ScratchCardView(
                answer: quiz.answer,
                isUnlocked: state.unlockedIndices.contains(index),
                isRevealed: state.revealedIndices.contains(index),
                isAdReady: state.isAdReady,
                onRequestAd: { onUnlock(index) },
                onCompleted: { state.revealedIndices.insert(index) }
            )
        }
        .accessibilityElement(children: .contain)
    }
}

extension ResultScreen {
    /// 背景に出す足の数
    static var legCount: Int { LegSlot.result.count }
}

private let previewLegs = ["kirin", "zou", "huramingo", "neko", "tako", "ahiru", "batta", "kaba", "pengin", "simauma"]

private let previewQuizzes: [Quiz] = [
    Quiz(image: "kirin.png", answer: "きりん", url: "", choice: Choice(a: "きりん", b: "いぬ", c: "ねこ", d: "ぞう")),
    Quiz(image: "zou.png", answer: "ぞう", url: "", choice: Choice(a: "きりん", b: "いぬ", c: "ねこ", d: "ぞう")),
    Quiz(image: "simauma.png", answer: "しまうま", url: "", choice: Choice(a: "きりん", b: "いぬ", c: "しまうま", d: "ぞう"))
]

private func previewState(unlocked: Set<Int> = [], isAdReady: Bool = true) -> ResultScreenState {
    let state = ResultScreenState()
    state.unlockedIndices = unlocked
    state.isAdReady = isAdReady
    return state
}

#Preview("Good") {
    ResultScreen(score: 10, wrongQuizzes: [], legImageNames: previewLegs, state: previewState(), onUnlock: { _ in })
}

#Preview("Normal") {
    ResultScreen(score: 7, wrongQuizzes: previewQuizzes, legImageNames: previewLegs, state: previewState(unlocked: [1]), onUnlock: { _ in })
}

#Preview("Bad") {
    ResultScreen(
        score: 3,
        wrongQuizzes: Array(repeating: previewQuizzes, count: 3).flatMap { $0 },
        legImageNames: previewLegs,
        state: previewState(isAdReady: false),
        onUnlock: { _ in }
    )
}
