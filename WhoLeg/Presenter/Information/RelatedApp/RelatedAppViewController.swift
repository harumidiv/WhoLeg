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
        title = "関連アプリ"
        rootView = RelatedAppScreen(sections: makeSections(), onDownload: { [weak self] id in
            self?.showStore(appID: id)
        })
    }

    private func makeSections() -> [RelatedAppScreen.AppSection] {
        return [
            .init(name: "ゲーム", items: [
                .init(image: UIImage(named: "natto")!, title: "Oh!Natto!",
                      description: "納豆ネバネバ新感覚シミュレーションゲーム!\nやみつき間違いなし！！", appID: "1457049172"),
                .init(image: UIImage(named: "ebifly")!, title: "えびフライ",
                      description: "エビフライが空を飛ぶ！？きれいに揚げて宇宙を目指そう！", appID: "1461666071"),
                .init(image: UIImage(named: "munyu")!, title: "むにゅ",
                      description: "スマホを左右に傾けて森の中を進む！缶に注意して新記録を目指そう", appID: "1461761608")
            ]),
            .init(name: "ツール", items: [
                .init(image: UIImage(named: "rubi")!, title: "Rubi",
                      description: "どんな漢字も「ひらがな」と「カタカナ」に変換することができるアプリです", appID: "1471085589"),
                .init(image: UIImage(named: "toio-controller")!, title: "toio controller",
                      description: "dualshock4でtoioを簡単操作！\n本アプリを利用するにはtoioが必要です", appID: "1469030441")
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
