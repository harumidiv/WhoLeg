//
//  InformationViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/24.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit
import SwiftUI

enum PageType {
    case pictureBook
    case appAbout
    case relatedApp
}

struct InformationData {
    var label: String
    var pageType: PageType
}

class InformationViewController: UIHostingController<InformationScreen> {
    let jsonData: QuizInfo

    init(data: QuizInfo) {
        jsonData = data
        super.init(rootView: InformationScreen(
            onSelectPictureBook: {},
            onSelectAppAbout: {},
            onSelectRelatedApp: {}
        ))
    }

    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 図鑑画面でNavigationBarTitle位置をずらしたのを戻す
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(hex: "#0F9D58")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)
        navigationController?.navigationBar.standardAppearance = appearance
    }

    override func viewDidLoad() {
        title = "じょうほう"
        super.viewDidLoad()

        rootView = InformationScreen(
            onSelectPictureBook: { [weak self] in
                guard let self else { return }
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                self.navigationController?.pushViewController(PictureBookViewController(data: self.jsonData), animated: true)
            },
            onSelectAppAbout: { [weak self] in
                guard let self else { return }
                self.navigationController?.pushViewController(AppAboutViewController(), animated: true)
            },
            onSelectRelatedApp: { [weak self] in
                guard let self else { return }
                self.navigationController?.pushViewController(RelatedAppViewController(), animated: true)
            }
        )
    }
}
