//
//  LegBurstView.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/11/11.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import SwiftUI
import UIKit

/// 足を出す位置
struct LegSlot {
    /// 足の付け根を置く画面のふちの位置（画面に対する割合）
    let edgePoint: UnitPoint
    /// 足先が向く方向を決める回転角。0で上から下へ伸びる
    let angle: Double
    /// 画面の短い辺に対する足の画像の大きさ
    let sizeRatio: CGFloat
}

/// 画面のまわりから、いろいろな足がニョキっと出てくる背景
struct LegBurstView: View {
    enum Motion {
        /// バネのようにポンと飛び出す
        case pop
        /// 画面の外からゆっくり生えてくる
        case grow

        var animation: Animation {
            switch self {
            case .pop: return .spring(response: 0.5, dampingFraction: 0.55)
            case .grow: return .spring(response: 0.55, dampingFraction: 0.8)
            }
        }

        var stagger: Double {
            switch self {
            case .pop: return 0.04
            case .grow: return 0.035
            }
        }
    }

    let imageNames: [String]
    let slots: [LegSlot]
    var motion: Motion = .pop
    /// 出てきたあと、ゆらゆら揺らし続けるか
    var sways: Bool = true
    /// falseの間は画面の外で待たせる。trueになった瞬間に出てくる（音と合わせたいときに使う）
    var isStarted: Bool = true
    /// 足が出てくる順番（slotsの添字の並び）。nilならslotsの並び順に出てくる
    var appearanceOrder: [Int]? = nil
    /// あらかじめデコードしておいた画像。あればアセットの代わりに使い、出てくる途中でカクつかないようにする
    var preparedImages: [String: UIImage] = [:]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAppeared = false
    @State private var isSwaying = false

    /// 足の付け根を画面の外に隠しておく割合
    private let overhang: CGFloat = 0.18

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let base = min(min(size.width, size.height), 600)
            ZStack {
                ForEach(Array(zip(slots.indices, imageNames)), id: \.0) { index, imageName in
                    leg(imageName: imageName, slot: slots[index], index: index, base: base, screenSize: size)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear {
            if isStarted { start() }
        }
        .onChange(of: isStarted) { _, started in
            if started { start() }
        }
    }

    private func start() {
        guard !isAppeared else { return }
        if reduceMotion {
            isAppeared = true
            return
        }
        withAnimation(motion.animation) {
            isAppeared = true
        }
        guard sways else { return }
        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(0.6)) {
            isSwaying = true
        }
    }

    /// その足が何番目に出てくるか
    private func appearanceRank(of index: Int) -> Int {
        appearanceOrder?.firstIndex(of: index) ?? index
    }

    /// 足の画像を表示する大きさに縮めて、バックグラウンドでデコードしておく。
    /// 元の画像は大きいので、そのまま何枚も出すとメモリを使い、出てくる途中でカクつくため
    static func prepareImages(named names: [String], maxPixelSize: CGFloat) async -> [String: UIImage] {
        let target = CGSize(width: maxPixelSize, height: maxPixelSize)
        return await withTaskGroup(of: (String, UIImage?).self) { group in
            for name in Set(names) {
                group.addTask {
                    (name, await UIImage(named: name)?.byPreparingThumbnail(ofSize: target))
                }
            }
            var images: [String: UIImage] = [:]
            for await (name, image) in group {
                images[name] = image
            }
            return images
        }
    }

    private func image(named name: String) -> Image {
        if let prepared = preparedImages[name] {
            return Image(uiImage: prepared)
        }
        return Image(name)
    }

    private func leg(imageName: String, slot: LegSlot, index: Int, base: CGFloat, screenSize: CGSize) -> some View {
        let legSize = base * slot.sizeRatio
        let radians = slot.angle * .pi / 180
        // 画像の上側（足の付け根）を画面の外へ向け、足先が画面の内側へ伸びるように配置する
        let inward = CGPoint(x: -sin(radians), y: cos(radians))
        let edge = CGPoint(x: slot.edgePoint.x * screenSize.width, y: slot.edgePoint.y * screenSize.height)
        let distance = legSize * (0.5 - overhang)
        let center = CGPoint(x: edge.x + inward.x * distance, y: edge.y + inward.y * distance)
        // ゆらゆらする向きと強さを足ごとに少し変える
        let sway = sways ? (index.isMultiple(of: 2) ? 1.0 : -1.0) * (2.5 + Double(index % 3)) : 0

        return image(named: imageName)
            .resizable()
            .scaledToFit()
            .frame(width: legSize, height: legSize)
            .rotationEffect(.degrees(isSwaying ? sway : -sway), anchor: .top)
            // 出てくる前は、足先がちょうど画面のふちに隠れる位置で待たせる。
            // 動き出した瞬間に見え始めるので、音や間隔とずれない
            .offset(y: isAppeared ? 0 : -legSize * (1 - overhang))
            .rotationEffect(.degrees(slot.angle))
            .position(center)
            .animation(
                reduceMotion ? nil : motion.animation.delay(Double(appearanceRank(of: index)) * motion.stagger),
                value: isAppeared
            )
    }
}

extension LegSlot {
    /// 結果画面用。ボタンは真ん中にまとめたので、上下左右と四すみの22か所から出す
    static let result: [LegSlot] = [
        // 上
        LegSlot(edgePoint: UnitPoint(x: 0.1, y: 0), angle: 8, sizeRatio: 0.36),
        LegSlot(edgePoint: UnitPoint(x: 0.3, y: 0), angle: -6, sizeRatio: 0.32),
        LegSlot(edgePoint: UnitPoint(x: 0.5, y: 0), angle: 3, sizeRatio: 0.34),
        LegSlot(edgePoint: UnitPoint(x: 0.7, y: 0), angle: -4, sizeRatio: 0.3),
        LegSlot(edgePoint: UnitPoint(x: 0.9, y: 0), angle: -10, sizeRatio: 0.36),
        // 右上
        LegSlot(edgePoint: UnitPoint(x: 1, y: 0), angle: 45, sizeRatio: 0.34),
        // 右
        LegSlot(edgePoint: UnitPoint(x: 1, y: 0.22), angle: 100, sizeRatio: 0.34),
        LegSlot(edgePoint: UnitPoint(x: 1, y: 0.42), angle: 84, sizeRatio: 0.38),
        LegSlot(edgePoint: UnitPoint(x: 1, y: 0.62), angle: 96, sizeRatio: 0.34),
        LegSlot(edgePoint: UnitPoint(x: 1, y: 0.8), angle: 80, sizeRatio: 0.38),
        // 右下
        LegSlot(edgePoint: UnitPoint(x: 1, y: 1), angle: 135, sizeRatio: 0.42),
        // 下
        LegSlot(edgePoint: UnitPoint(x: 0.88, y: 1), angle: 172, sizeRatio: 0.4),
        LegSlot(edgePoint: UnitPoint(x: 0.68, y: 1), angle: 186, sizeRatio: 0.36),
        LegSlot(edgePoint: UnitPoint(x: 0.5, y: 1), angle: 178, sizeRatio: 0.4),
        LegSlot(edgePoint: UnitPoint(x: 0.32, y: 1), angle: 190, sizeRatio: 0.36),
        LegSlot(edgePoint: UnitPoint(x: 0.12, y: 1), angle: 184, sizeRatio: 0.4),
        // 左下
        LegSlot(edgePoint: UnitPoint(x: 0, y: 1), angle: -135, sizeRatio: 0.4),
        // 左
        LegSlot(edgePoint: UnitPoint(x: 0, y: 0.78), angle: -82, sizeRatio: 0.38),
        LegSlot(edgePoint: UnitPoint(x: 0, y: 0.6), angle: -96, sizeRatio: 0.34),
        LegSlot(edgePoint: UnitPoint(x: 0, y: 0.42), angle: -86, sizeRatio: 0.38),
        LegSlot(edgePoint: UnitPoint(x: 0, y: 0.22), angle: -100, sizeRatio: 0.34),
        // 左上
        LegSlot(edgePoint: UnitPoint(x: 0, y: 0), angle: -45, sizeRatio: 0.34),
    ]

    /// 結果画面で足が出てくる順番。反対側や別の辺へ飛びながら四方八方から出てくるようにする
    /// （0〜4: 上、5: 右上、6〜9: 右、10: 右下、11〜15: 下、16: 左下、17〜20: 左、21: 左上）
    static let resultOrder: [Int] = [
        2, 13, 19, 8, 21, 10, 5, 16,
        0, 15, 20, 7, 4, 11, 17, 6,
        1, 14, 18, 9, 3, 12,
    ]

    /// スプラッシュ画面用。細長い足を画面の四辺と四すみからたくさん出して、外から生えているように見せる。
    /// 上の左から時計回りに並べている（出てくる順番は splashOrder）
    static let splash: [LegSlot] = [
        // 上
        LegSlot(edgePoint: UnitPoint(x: 0.1, y: 0), angle: 6, sizeRatio: 0.58),
        LegSlot(edgePoint: UnitPoint(x: 0.3, y: 0), angle: -4, sizeRatio: 0.52),
        LegSlot(edgePoint: UnitPoint(x: 0.5, y: 0), angle: 2, sizeRatio: 0.56),
        LegSlot(edgePoint: UnitPoint(x: 0.7, y: 0), angle: -6, sizeRatio: 0.5),
        LegSlot(edgePoint: UnitPoint(x: 0.9, y: 0), angle: -10, sizeRatio: 0.56),
        // 右上
        LegSlot(edgePoint: UnitPoint(x: 1, y: 0), angle: 45, sizeRatio: 0.5),
        // 右
        LegSlot(edgePoint: UnitPoint(x: 1, y: 0.18), angle: 100, sizeRatio: 0.5),
        LegSlot(edgePoint: UnitPoint(x: 1, y: 0.34), angle: 86, sizeRatio: 0.54),
        LegSlot(edgePoint: UnitPoint(x: 1, y: 0.5), angle: 94, sizeRatio: 0.5),
        LegSlot(edgePoint: UnitPoint(x: 1, y: 0.66), angle: 82, sizeRatio: 0.54),
        LegSlot(edgePoint: UnitPoint(x: 1, y: 0.82), angle: 96, sizeRatio: 0.5),
        // 右下
        LegSlot(edgePoint: UnitPoint(x: 1, y: 1), angle: 135, sizeRatio: 0.54),
        // 下
        LegSlot(edgePoint: UnitPoint(x: 0.9, y: 1), angle: 172, sizeRatio: 0.54),
        LegSlot(edgePoint: UnitPoint(x: 0.7, y: 1), angle: 186, sizeRatio: 0.5),
        LegSlot(edgePoint: UnitPoint(x: 0.5, y: 1), angle: 178, sizeRatio: 0.56),
        LegSlot(edgePoint: UnitPoint(x: 0.3, y: 1), angle: 184, sizeRatio: 0.5),
        LegSlot(edgePoint: UnitPoint(x: 0.1, y: 1), angle: 190, sizeRatio: 0.54),
        // 左下
        LegSlot(edgePoint: UnitPoint(x: 0, y: 1), angle: -135, sizeRatio: 0.52),
        // 左
        LegSlot(edgePoint: UnitPoint(x: 0, y: 0.82), angle: -84, sizeRatio: 0.5),
        LegSlot(edgePoint: UnitPoint(x: 0, y: 0.66), angle: -96, sizeRatio: 0.54),
        LegSlot(edgePoint: UnitPoint(x: 0, y: 0.5), angle: -88, sizeRatio: 0.5),
        LegSlot(edgePoint: UnitPoint(x: 0, y: 0.34), angle: -100, sizeRatio: 0.54),
        LegSlot(edgePoint: UnitPoint(x: 0, y: 0.18), angle: -82, sizeRatio: 0.5),
        // 左上
        LegSlot(edgePoint: UnitPoint(x: 0, y: 0), angle: -45, sizeRatio: 0.5),
    ]

    /// スプラッシュで足が出てくる順番。ぐるっと回らず、反対側や別の辺へ飛びながら四方八方から出てくるようにする
    /// （0〜4: 上、5: 右上、6〜10: 右、11: 右下、12〜16: 下、17: 左下、18〜22: 左、23: 左上）
    static let splashOrder: [Int] = [
        2, 14, 20, 8, 23, 11, 5, 17,
        0, 16, 22, 10, 4, 12, 18, 6,
        1, 15, 21, 9, 3, 13, 19, 7,
    ]
}

#Preview("スプラッシュの足") {
    ZStack {
        Color("Background")
        LegBurstView(imageNames: SplashScreen.legImageNames, slots: LegSlot.splash, motion: .grow, sways: false)
    }
    .ignoresSafeArea()
}
