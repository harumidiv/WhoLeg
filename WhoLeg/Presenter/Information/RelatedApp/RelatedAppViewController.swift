//
//  RelatedAppViewController.swift
//  WhoLeg
//
//  Created by 佐川 晴海 on 2020/05/23.
//  Copyright © 2020 佐川晴海. All rights reserved.
//

import UIKit

class RelatedAppViewController: UIViewController {
    struct CellViewModel {
        var image: UIImage
        var title: String
        var description: String
        var appID: String
    }

    private let secrion = ["ゲーム", "ツール"]
    private let viewModel: [[CellViewModel]] = [[CellViewModel(image: UIImage(named: "natto")!,
                                                               title: "Oh!Natto!",
                                                               description: "納豆ネバネバ新感覚シミュレーションゲーム!\nやみつき間違いなし！！",
                                                               appID: "1457049172"),
                                                 CellViewModel(image: UIImage(named: "ebifly")!,
                                                               title: "えびフライ",
                                                               description: "エビフライが空を飛ぶ！？きれいに揚げて宇宙を目指そう！",
                                                               appID: "1461666071"),
                                                 CellViewModel(image: UIImage(named: "munyu")!,
                                                               title: "むにゅ",
                                                               description: "スマホを左右に傾けて森の中を進む！缶に注意して新記録を目指そう",
                                                               appID: "1461761608")],
                                                // -------ツール-------
                                                [CellViewModel(image: UIImage(named: "rubi")!,
                                                               title: "Rubi",
                                                               description: "どんな漢字も「ひらがな」と「カタカナ」に変換することができるアプリです",
                                                               appID: "1471085589"),
                                                 CellViewModel(image: UIImage(named: "toio-controller")!,
                                                               title: "toio controller",
                                                               description: "dualshock4でtoioを簡単操作！\n本アプリを利用するにはtoioが必要です",
                                                               appID: "1469030441")]]
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(cellType: RelatedAppTableViewCell.self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "関連アプリ"
    }
}

extension RelatedAppViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return secrion.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel[section].count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: RelatedAppTableViewCell.self, for: indexPath)
        cell.setup(cellViewModel: viewModel[indexPath.section][indexPath.row], buttonAction: { (id) -> Void in
            print(id)
            //TODOストアを開く
        })
        return cell
    }
}
