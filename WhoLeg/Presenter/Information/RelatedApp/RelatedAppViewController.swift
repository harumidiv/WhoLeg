//
//  RelatedAppViewController.swift
//  WhoLeg
//
//  Created by 佐川 晴海 on 2020/05/23.
//  Copyright © 2020 佐川晴海. All rights reserved.
//

import StoreKit
import SwiftUI
import UIKit

class RelatedAppViewController: UIHostingController<RelatedAppScreen>, SKStoreProductViewControllerDelegate {
    // Keep for RelatedAppTableViewCell backward compatibility
    struct CellViewModel {
        var image: UIImage
        var title: String
        var description: String
        var appID: String
    }

    private var isNotStoreOpen: Bool = true

    init() {
        super.init(rootView: RelatedAppScreen(sections: [], onDownload: { _ in }))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: "関連アプリ")
        rootView = RelatedAppScreen(sections: makeSections(), onDownload: { [weak self] id in
            self?.showStore(appID: id)
        })
    }

    private func makeSections() -> [RelatedAppScreen.AppSection] {
        return [
            .init(name: String(localized: "ゲーム"), items: [
                .init(image: UIImage(named: "image-tower")!, title: "のっけタワー",
                      description: String(localized: "写真から切り抜いた被写体を積み上げて、どこまで高く積めるかチャレンジ！"), appID: "6822193103"),
                .init(image: UIImage(named: "kuttuke")!, title: "くっつけ",
                      description: String(localized: "じぶんの写真を切り抜いて遊ぶ、写真がくっついて進化する落ちものパズル"), appID: "6820843882"),
                .init(image: UIImage(named: "natto")!, title: "Oh!Natto!",
                      description: String(localized: "納豆ネバネバ新感覚シミュレーションゲーム!\nやみつき間違いなし！！"), appID: "1457049172"),
                .init(image: UIImage(named: "ebifly")!, title: "えびフライ",
                      description: String(localized: "エビフライが空を飛ぶ！？きれいに揚げて宇宙を目指そう！"), appID: "1461666071"),
                .init(image: UIImage(named: "munyu")!, title: "むにゅ",
                      description: String(localized: "スマホを左右に傾けて森の中を進む！缶に注意して新記録を目指そう"), appID: "1461761608")
            ]),
            .init(name: String(localized: "まなび"), items: [
                .init(image: UIImage(named: "sakata-dojo")!, title: "酒田道場",
                      description: String(localized: "実例チャートでローソク足30パターンをクイズと図鑑で学べるアプリ"), appID: "6798115410"),
                .init(image: UIImage(named: "kodo")!, title: "Kodo-心臓博物館",
                      description: String(localized: "生き物によって違う心臓の鼓動の速さを、手の中で感じてみよう"), appID: "6444230294")
            ]),
            .init(name: String(localized: "エンタメ"), items: [
                .init(image: UIImage(named: "ai-haiku-battle")!, title: "AI俳句バトル",
                      description: String(localized: "俳句とAIを融合させた、新感覚の言葉遊びアプリ"), appID: "6753979897"),
                .init(image: UIImage(named: "anime-techo")!, title: "アニメ手帳",
                      description: String(localized: "今期視聴しているアニメを一括管理！見ているサイトに直接飛べる"), appID: "1556976347"),
                .init(image: UIImage(named: "peronome")!, title: "ぺろのーむ",
                      description: String(localized: "振り子の動作をアメを舐める動きで表現したメトロノームアプリ"), appID: "1454250247"),
                .init(image: UIImage(named: "toio-controller")!, title: "toio controller",
                      description: String(localized: "dualshock4でtoioを簡単操作！\n本アプリを利用するにはtoioが必要です"), appID: "1469030441")
            ]),
            .init(name: String(localized: "ツール"), items: [
                .init(image: UIImage(named: "kabusenki")!, title: "かぶ戦記",
                      description: String(localized: "株のトレードで戦った記録を、感情やメモとともに記録するアプリ"), appID: "6752121856"),
                .init(image: UIImage(named: "manga-shiori")!, title: "まんがのしおり",
                      description: String(localized: "何巻・何話まで読んだかを記録できる、漫画のしおりアプリ"), appID: "6469087739"),
                .init(image: UIImage(named: "tapreco")!, title: "たぷれこ",
                      description: String(localized: "いつでもワンタップで録音ができる防犯アプリ"), appID: "6443822117"),
                .init(image: UIImage(named: "switch-capture")!, title: "Switchキャプチャー",
                      description: String(localized: "Switchのキャプチャを扱うユーティリティ。iPadでゲームを楽しめます"), appID: "6471073089")
            ])
        ]
    }

    private func showStore(appID: String) {
        guard isNotStoreOpen else { return }
        let vc = SKStoreProductViewController()
        vc.delegate = self
        let parameters = [SKStoreProductParameterITunesItemIdentifier: appID]
        vc.loadProduct(withParameters: parameters) { [weak self] status, error in
            guard let self else { return }
            if status {
                self.present(vc, animated: true)
            } else if let error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        isNotStoreOpen = true
    }
}
