//
//  ConfettiView.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/11/12.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import SwiftUI
import UIKit

/// 全問正解のときに画面の上から降らせる紙吹雪
struct ConfettiView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pieces: [Piece] = []
    @State private var startDate = Date()
    @State private var isFinished = false

    /// 降らせる紙の枚数
    private let count = 150
    /// 降り終わって片付けるまでの時間（秒）
    private let lifetime: TimeInterval = 8
    /// 最後のこの秒数で、残っている紙をふわっと消す
    private let fadeOutDuration: TimeInterval = 1.5

    var body: some View {
        if reduceMotion || isFinished {
            // 「視差効果を減らす」がオンなら降らせない
            Color.clear
        } else {
            GeometryReader { geometry in
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let elapsed = timeline.date.timeIntervalSince(startDate)
                        let fade = min(1, max(0, (lifetime - elapsed) / fadeOutDuration))
                        for piece in pieces {
                            draw(piece, in: &context, size: size, elapsed: elapsed, opacity: fade)
                        }
                    }
                }
                .onAppear {
                    pieces = Self.makePieces(count: count, in: geometry.size)
                    startDate = Date()
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(lifetime))
                isFinished = true
            }
        }
    }

    // MARK: - 紙の動き

    private struct Piece {
        let startX: CGFloat
        let startY: CGFloat
        /// 落ちる速さ（pt/秒）。紙はすぐに一定の速さになるので等速にする
        let fallSpeed: CGFloat
        /// 横に流れる速さ（pt/秒）
        let drift: CGFloat
        /// ひらひら左右にゆれる幅と速さ
        let swayAmplitude: CGFloat
        let swayFrequency: Double
        let swayPhase: Double
        /// くるくる回る速さと、裏返る速さ（ラジアン/秒）
        let spin: Double
        let flip: Double
        let size: CGSize
        let isRound: Bool
        let color: Color
    }

    /// 背景のオレンジに埋もれない色にする
    private static let colors: [Color] = [
        Color(UIColor(hex: "#FFFFFF")),
        Color(UIColor(hex: "#F4B400")),
        Color(UIColor(hex: "#0F9D58")),
        Color(UIColor(hex: "#3D8BFD")),
        Color(UIColor(hex: "#FF4F8B")),
        Color(UIColor(hex: "#9B5DE5")),
    ]

    private static func makePieces(count: Int, in size: CGSize) -> [Piece] {
        (0 ..< count).map { index in
            // 最初の3分の1は画面のすぐ上に並べて、表示した瞬間にどっと降ってくるようにする
            let isBurst = index < count / 3
            let startY = isBurst
                ? CGFloat.random(in: -size.height * 0.15 ... -10)
                : CGFloat.random(in: -size.height * 0.7 ... -size.height * 0.15)
            let isRound = Double.random(in: 0 ... 1) < 0.2
            let width = CGFloat.random(in: 6 ... 10)
            return Piece(
                startX: CGFloat.random(in: -20 ... size.width + 20),
                startY: startY,
                fallSpeed: CGFloat.random(in: 150 ... 260),
                drift: CGFloat.random(in: -30 ... 30),
                swayAmplitude: CGFloat.random(in: 8 ... 26),
                swayFrequency: Double.random(in: 0.6 ... 1.6),
                swayPhase: Double.random(in: 0 ... .pi * 2),
                spin: Double.random(in: -6 ... 6),
                flip: Double.random(in: 4 ... 10),
                size: isRound ? CGSize(width: width * 0.8, height: width * 0.8) : CGSize(width: width, height: width * 0.55),
                isRound: isRound,
                color: colors.randomElement() ?? .white
            )
        }
    }

    private func draw(_ piece: Piece, in context: inout GraphicsContext, size: CGSize, elapsed: TimeInterval, opacity: Double) {
        let t = CGFloat(elapsed)
        let y = piece.startY + piece.fallSpeed * t
        // 画面の下まで落ちきった紙は描かない
        guard y < size.height + 20 else { return }
        let sway = piece.swayAmplitude * CGFloat(sin(piece.swayFrequency * 2 * .pi * elapsed + piece.swayPhase))
        let x = piece.startX + piece.drift * t + sway

        var paper = context
        paper.opacity = opacity
        paper.translateBy(x: x, y: y)
        paper.rotate(by: .radians(piece.spin * elapsed))
        // 縦につぶしたり戻したりして、紙が裏返りながら落ちるように見せる
        let flip = cos(piece.flip * elapsed)
        paper.scaleBy(x: 1, y: max(abs(CGFloat(flip)), 0.08))
        let rect = CGRect(x: -piece.size.width / 2, y: -piece.size.height / 2, width: piece.size.width, height: piece.size.height)
        let path = piece.isRound ? Path(ellipseIn: rect) : Path(rect)
        paper.fill(path, with: .color(piece.color))
        // 裏側が見えているときは少し暗くして立体感を出す
        if flip < 0 {
            paper.fill(path, with: .color(.black.opacity(0.18)))
        }
    }
}

#Preview {
    ZStack {
        Color(red: 1, green: 0.485, blue: 0.226)
        ConfettiView()
    }
    .ignoresSafeArea()
}
