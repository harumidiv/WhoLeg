//
//  BannerAdView.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2026/10/28.
//  Copyright © 2026 佐川晴海. All rights reserved.
//

import GoogleMobileAds
import SwiftUI

/// 画面幅に合わせて高さが決まるアダプティブバナー広告
struct BannerAdView: View {
    @State private var width: CGFloat = 0

    var body: some View {
        ZStack {
            if width > 0 {
                let adSize = largeAnchoredAdaptiveBanner(width: width)
                BannerViewContainer(adSize: adSize)
                    .frame(width: adSize.size.width, height: adSize.size.height)
                    // 回転などで幅が変わったら作り直してサイズに合った広告を読み込む
                    .id(width)
            }
        }
        .frame(maxWidth: .infinity)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
    }
}

private struct BannerViewContainer: UIViewRepresentable {
    #if DEBUG
    // 開発中は本番広告を表示・タップしないようにGoogleのテスト用広告ユニットを使う
    private let adUnitID = "ca-app-pub-3940256099942544/2435281174"
    #else
    private let adUnitID = "ca-app-pub-8522231452310619/6346338840"
    #endif

    let adSize: AdSize

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = adUnitID
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
