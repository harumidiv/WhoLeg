//
//  SplashScreen.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/11/11.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import SwiftUI
import UIKit

/// 起動画面（Info.plist の UILaunchScreen で背景色だけ表示）の続きとして、ロゴのまわりから足が生えてくる画面
struct SplashScreen: View {
    let onFinish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var didFinish = false
    @State private var isStarted = false
    @State private var isLogoVisible = false
    @State private var preparedImages: [String: UIImage] = [:]

    /// 画面の外から生やす足。ランダムにせず、細長い足を固定で並べる（LegSlot.splash と同じ順番）
    static let legImageNames = [
        // 上
        "oneetyan", "sika", "kirin", "ninja", "santa",
        // 右上
        "hakutyou",
        // 右
        "huramingo", "yagi", "neko", "datyou", "raion",
        // 右下
        "aosagi",
        // 下
        "uma", "robotto", "zou", "bareri-na", "tora",
        // 左下
        "ta-ki-",
        // 左
        "simauma", "perikan", "kasaobake", "arupaka", "turu",
        // 左上
        "inosisi",
    ]

    var body: some View {
        ZStack {
            // 起動画面と同じ背景色（ダークモード対応の "Background"）にして、切り替わりを目立たなくする
            Color("Background")
                .ignoresSafeArea()

            // 起動画面は背景色だけなので、ロゴはふわっと出す
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .offset(y: -25)
                .opacity(isLogoVisible ? 1 : 0)
                .scaleEffect(isLogoVisible || reduceMotion ? 1 : 0.92)
                .accessibilityLabel("だれのあし？")

            // 足はロゴより手前に出して、ロゴに重なってもよいことにする
            LegBurstView(
                imageNames: Self.legImageNames,
                slots: LegSlot.splash,
                motion: .grow,
                sways: false,
                isStarted: isStarted,
                appearanceOrder: LegSlot.splashOrder,
                preparedImages: preparedImages
            )
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        // 待ちたくない人はタップで飛ばせる
        .onTapGesture { finish() }
        .onAppear {
            withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 0.25)) {
                isLogoVisible = true
            }
        }
        .task {
            // 起動直後に大きな画像をデコードするとアニメーションがカクついて音とずれるので、
            // 画像と音を先に準備してから、足と音を同時にスタートさせる
            if !reduceMotion {
                PopSoundPlayer.shared.prepare()
            }
            preparedImages = await Self.prepareImages()
            // 準備した画像で1フレーム描いてから動かし始める
            try? await Task.sleep(for: .milliseconds(50))

            isStarted = true
            if !reduceMotion {
                // 足が1本出てくるごとに「ぽ」と鳴らす
                PopSoundPlayer.shared.playPops(count: Self.legImageNames.count, interval: LegBurstView.Motion.grow.stagger)
            }

            // 足が出そろって少し見せてからタイトルへ進む（スプラッシュ全体で1.5秒くらい）
            try? await Task.sleep(for: .seconds(reduceMotion ? 1.0 : 1.45))
            finish()
        }
    }

    /// 足の画像を表示する大きさに縮めてデコードしておく
    private static func prepareImages() async -> [String: UIImage] {
        // 足は画面の短い辺の6割弱なので、3倍の解像度でも足りる大きさにする（数が多いのでメモリも抑える）
        let target = CGSize(width: 680, height: 680)
        return await withTaskGroup(of: (String, UIImage?).self) { group in
            for name in legImageNames {
                group.addTask {
                    let image = await UIImage(named: name)?.byPreparingThumbnail(ofSize: target)
                    return (name, image)
                }
            }
            var images: [String: UIImage] = [:]
            for await (name, image) in group {
                images[name] = image
            }
            return images
        }
    }

    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        onFinish()
    }
}

final class SplashViewController: UIHostingController<SplashScreen> {
    init(onFinish: @escaping () -> Void) {
        super.init(rootView: SplashScreen(onFinish: onFinish))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    SplashScreen(onFinish: {})
}
