//
//  ScratchCardView.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/11/11.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import Combine
import CoreMotion
import SwiftUI
import UIKit

/// 端末の傾きを配信する。スクラッチの銀はくの反射を動かすのに使う
@MainActor
final class TiltMotion: ObservableObject {
    static let shared = TiltMotion()

    /// 左右(dx)・前後(dy)の傾き。-1〜1
    @Published private(set) var tilt: CGVector = .zero

    private let manager = CMMotionManager()
    private var users = 0

    func start() {
        users += 1
        guard users == 1, manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 30.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let gravity = motion?.gravity else { return }
            // 手に持って少し手前に傾けた状態を真ん中にする
            let dx = max(-1, min(1, gravity.x))
            let dy = max(-1, min(1, gravity.y + 0.6))
            MainActor.assumeIsolated {
                self?.tilt = CGVector(dx: dx, dy: dy)
            }
        }
    }

    func stop() {
        users = max(0, users - 1)
        guard users == 0 else { return }
        manager.stopDeviceMotionUpdates()
    }
}

/// 広告を見たあと、指で削って答えを見るスクラッチ
struct ScratchCardView: View {
    let answer: String
    /// 広告を見て、削れる状態になっていればtrue
    let isUnlocked: Bool
    /// すでに削り終えていればtrue
    let isRevealed: Bool
    let isAdReady: Bool
    let onRequestAd: () -> Void
    let onCompleted: () -> Void

    @ObservedObject private var motion = TiltMotion.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// なぞった点。x < 0 の点はなぞりの区切り
    @State private var points: [CGPoint] = []
    @State private var coveredCells: Set<Int> = []
    @State private var size: CGSize = .zero
    @State private var fade: Double = 1
    @State private var isFinished = false
    @State private var flakes: [Flake] = []
    @State private var lastSample: (point: CGPoint, time: Date)?
    @State private var distanceSinceHaptic: CGFloat = 0

    init(
        answer: String,
        isUnlocked: Bool,
        isRevealed: Bool,
        isAdReady: Bool,
        onRequestAd: @escaping () -> Void,
        onCompleted: @escaping () -> Void,
        initialPoints: [CGPoint] = []
    ) {
        self.answer = answer
        self.isUnlocked = isUnlocked
        self.isRevealed = isRevealed
        self.isAdReady = isAdReady
        self.onRequestAd = onRequestAd
        self.onCompleted = onCompleted
        // プレビューで削り跡を確認するための初期値
        _points = State(initialValue: initialPoints)
    }

    private let radius: CGFloat = 14
    private let cellSize: CGFloat = 6
    /// どこまで削るかはユーザーに任せる。ほぼ削りきって残りがわずかになったときだけ、細かい削り残しを消す
    private let fullyScratchedRatio = 0.95
    /// シェーダーに渡す点の上限。ここまでなぞったら十分削ったとみなす
    private let maxPoints = 400
    private let height: CGFloat = 52

    var body: some View {
        ZStack {
            answerLayer
            if showsFoil {
                foilLayer
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .onGeometryChange(for: CGSize.self) { $0.size } action: { size = $0 }
        .overlay(alignment: .top) { flakeLayer }
        .onAppear { if !reduceMotion { motion.start() } }
        .onDisappear {
            if !reduceMotion { motion.stop() }
            ScratchSoundPlayer.shared.stop()
        }
    }

    /// 自分で削り終えたときは消えるアニメーションの間だけ銀はくを残す
    private var showsFoil: Bool {
        isFinished ? fade > 0 : !isRevealed
    }

    private var answerLayer: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color(UIColor(hex: "#E9F7EF")))
            .overlay {
                Text(answer)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(UIColor(hex: "#0B7A44")))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 8)
            }
            // 削り終わるまでは読み上げない
            .accessibilityHidden(showsFoil)
    }

    @ViewBuilder
    private var foilLayer: some View {
        let foil = foilSurface
            .colorEffect(foilShader)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

        if isUnlocked {
            foil
                .contentShape(Rectangle())
                .highPriorityGesture(scratchGesture)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("スクラッチ")
                .accessibilityHint("ゆびで けずると こたえが でてきます")
                .accessibilityAction(named: "こたえを みる") { finish() }
        } else {
            // disabledにすると中身が半透明になり答えが透けてしまうので、押せない状態はactionの中で判定する
            Button {
                if isAdReady { onRequestAd() }
            } label: {
                foil
            }
            .buttonStyle(FoilButtonStyle())
            .accessibilityLabel(isAdReady ? "どうがを みて けずる" : "じゅんびちゅう")
            .accessibilityHint("広告を見ると、けずって答えを見られます")
        }
    }

    /// 銀はくの土台。質感と削り跡はシェーダーで付ける
    private var foilSurface: some View {
        ZStack {
            LinearGradient(
                colors: [Color(UIColor(hex: "#D5D9E0")), Color(UIColor(hex: "#AEB4BE")), Color(UIColor(hex: "#C8CDD5"))],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Label(foilLabel, systemImage: isUnlocked ? "hand.point.up.left.fill" : "play.fill")
                .font(.system(.subheadline, design: .rounded, weight: .heavy))
                .foregroundStyle(Color(UIColor(hex: "#2B3240")).opacity(isUnlocked || isAdReady ? 1 : 0.5))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 8)
        }
    }

    private var foilLabel: String {
        if isUnlocked { return "ゆびで けずってね" }
        return isAdReady ? "どうがを みて けずる" : "じゅんびちゅう"
    }

    private var foilShader: Shader {
        let tilt = reduceMotion ? .zero : motion.tilt
        // 点が1つもないとシェーダーに空配列を渡せないので、区切りの点を入れておく
        let flat: [Float] = points.isEmpty ? [-1, -1] : points.flatMap { [Float($0.x), Float($0.y)] }
        return ShaderLibrary.scratchFoil(
            .float2(size),
            .float2(tilt.dx, tilt.dy),
            .float(radius),
            .float(fade),
            .floatArray(flat)
        )
    }

    // MARK: - 削る操作

    private var scratchGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in scratch(at: value.location) }
            .onEnded { _ in
                points.append(CGPoint(x: -1, y: -1))
                lastSample = nil
                ScratchSoundPlayer.shared.stop()
            }
    }

    private func scratch(at location: CGPoint) {
        guard !isFinished, !isRevealed, size.width > 0 else { return }
        let now = Date()

        guard let last = lastSample else {
            // なぞり始め
            ScratchSoundPlayer.shared.prepare()
            addPoint(location)
            lastSample = (location, now)
            return
        }

        let moved = hypot(location.x - last.point.x, location.y - last.point.y)
        guard moved >= 4 else { return }

        let elapsed = max(now.timeIntervalSince(last.time), 1.0 / 120.0)
        ScratchSoundPlayer.shared.scratch(speed: moved / elapsed)
        addPoint(location, from: last.point)
        spawnFlakes(at: location, direction: CGPoint(x: location.x - last.point.x, y: location.y - last.point.y))
        playHapticIfNeeded(moved: moved)
        lastSample = (location, now)

        if coverage >= fullyScratchedRatio || points.count >= maxPoints {
            finish()
        }
    }

    private func addPoint(_ point: CGPoint, from previous: CGPoint? = nil) {
        points.append(point)
        // 線分に沿って削れたマスを記録し、どのくらい削ったかを数える
        let start = previous ?? point
        let steps = max(1, Int(hypot(point.x - start.x, point.y - start.y) / (cellSize / 2)))
        for step in 0 ... steps {
            let t = CGFloat(step) / CGFloat(steps)
            markCells(around: CGPoint(x: start.x + (point.x - start.x) * t, y: start.y + (point.y - start.y) * t))
        }
    }

    private func markCells(around point: CGPoint) {
        let columns = Int(ceil(size.width / cellSize))
        let rows = Int(ceil(size.height / cellSize))
        let reach = Int(ceil(radius / cellSize))
        let centerColumn = Int(point.x / cellSize)
        let centerRow = Int(point.y / cellSize)
        for row in (centerRow - reach) ... (centerRow + reach) where row >= 0 && row < rows {
            for column in (centerColumn - reach) ... (centerColumn + reach) where column >= 0 && column < columns {
                let cellCenter = CGPoint(x: (CGFloat(column) + 0.5) * cellSize, y: (CGFloat(row) + 0.5) * cellSize)
                if hypot(cellCenter.x - point.x, cellCenter.y - point.y) <= radius {
                    coveredCells.insert(row * columns + column)
                }
            }
        }
    }

    private var coverage: Double {
        let total = Int(ceil(size.width / cellSize)) * Int(ceil(size.height / cellSize))
        guard total > 0 else { return 0 }
        return Double(coveredCells.count) / Double(total)
    }

    private func finish() {
        guard !isFinished else { return }
        isFinished = true
        ScratchSoundPlayer.shared.stop()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.easeOut(duration: 0.35)) {
            fade = 0
        }
        onCompleted()
    }

    private func playHapticIfNeeded(moved: CGFloat) {
        distanceSinceHaptic += moved
        guard distanceSinceHaptic >= 10 else { return }
        distanceSinceHaptic = 0
        Haptics.scratch.impactOccurred(intensity: 0.55)
    }

    // MARK: - 削りカス

    private struct Flake: Identifiable {
        let id = UUID()
        let origin: CGPoint
        let velocity: CGVector
        let spin: Double
        let size: CGFloat
        let brightness: Double
        let born: Date
    }

    private static let flakeLifetime: TimeInterval = 0.8
    /// 削りカスが帯の外まで飛んでも見えるように、描画範囲を広げる量
    private static let flakeInset = CGSize(width: 40, height: 20)

    private func spawnFlakes(at point: CGPoint, direction: CGPoint) {
        guard !reduceMotion else { return }
        let now = Date()
        flakes.removeAll { now.timeIntervalSince($0.born) > Self.flakeLifetime }
        guard flakes.count < 60 else { return }
        for _ in 0 ..< Int.random(in: 1 ... 2) {
            flakes.append(Flake(
                origin: point,
                velocity: CGVector(
                    dx: -direction.x * CGFloat.random(in: 2 ... 6) + CGFloat.random(in: -40 ... 40),
                    dy: CGFloat.random(in: -60 ... 0)
                ),
                spin: Double.random(in: -10 ... 10),
                size: CGFloat.random(in: 2 ... 4.5),
                brightness: Double.random(in: 0.7 ... 0.95),
                born: now
            ))
        }
        // なぞるのをやめても、落ちきった削りカスは片付ける
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.flakeLifetime + 0.05) {
            let current = Date()
            flakes.removeAll { current.timeIntervalSince($0.born) > Self.flakeLifetime }
        }
    }

    private var flakeLayer: some View {
        let inset = Self.flakeInset
        return TimelineView(.animation(paused: flakes.isEmpty)) { timeline in
            Canvas { context, _ in
                let now = timeline.date
                for flake in flakes {
                    let t = now.timeIntervalSince(flake.born)
                    guard t >= 0, t < Self.flakeLifetime else { continue }
                    let gravity: CGFloat = 700
                    let x = flake.origin.x + flake.velocity.dx * t + inset.width
                    let y = flake.origin.y + flake.velocity.dy * t + 0.5 * gravity * t * t + inset.height
                    var piece = context
                    piece.opacity = 1 - t / Self.flakeLifetime
                    piece.translateBy(x: x, y: y)
                    piece.rotate(by: .radians(flake.spin * t))
                    let rect = CGRect(x: -flake.size / 2, y: -flake.size / 2, width: flake.size, height: flake.size * 0.7)
                    piece.fill(Path(rect), with: .color(Color(white: flake.brightness)))
                }
            }
        }
        .frame(width: size.width + inset.width * 2, height: size.height + inset.height + 60)
        .offset(y: -inset.height)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// 押すと少し沈むだけで、半透明にはならないボタン
private struct FoilButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

private enum Haptics {
    static let scratch = UIImpactFeedbackGenerator(style: .soft)
}

#Preview {
    VStack(spacing: 12) {
        ScratchCardView(answer: "かに", isUnlocked: true, isRevealed: false, isAdReady: true, onRequestAd: {}, onCompleted: {})
        ScratchCardView(
            answer: "しばいぬ", isUnlocked: true, isRevealed: false, isAdReady: true, onRequestAd: {}, onCompleted: {},
            initialPoints: [
                CGPoint(x: 30, y: 18), CGPoint(x: 70, y: 30), CGPoint(x: 110, y: 20), CGPoint(x: 150, y: 34),
                CGPoint(x: -1, y: -1),
                CGPoint(x: 60, y: 40), CGPoint(x: 120, y: 38), CGPoint(x: 170, y: 16)
            ]
        )
        ScratchCardView(answer: "ねこ", isUnlocked: false, isRevealed: false, isAdReady: true, onRequestAd: {}, onCompleted: {})
        ScratchCardView(answer: "ぞう", isUnlocked: false, isRevealed: false, isAdReady: false, onRequestAd: {}, onCompleted: {})
    }
    .padding()
}
