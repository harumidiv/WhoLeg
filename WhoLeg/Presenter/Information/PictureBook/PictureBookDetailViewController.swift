//
//  PictureBookDetailViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/10/13.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import SafariServices
import UIKit
import SwiftUI

class PictureBookDetailViewController: UIHostingController<PictureBookDetailScreen> {
    private let viewModel: PictureBookDetailScreen.ViewModel

    init(viewModel: PictureBookDetailScreen.ViewModel) {
        self.viewModel = viewModel
        super.init(rootView: PictureBookDetailScreen(viewModel: viewModel, onDetailTapped: {}))
    }

    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "クイズ詳細"
        navigationItem.largeTitleDisplayMode = .never

        rootView = PictureBookDetailScreen(viewModel: viewModel, onDetailTapped: { [weak self] in
            guard let self else { return }
            let vc = SFSafariViewController(url: self.viewModel.url)
            self.present(vc, animated: true)
        })
    }
}
