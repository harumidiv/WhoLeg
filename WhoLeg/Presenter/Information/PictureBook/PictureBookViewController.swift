//
//  PictureBookViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/24.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit
import SwiftUI

class PictureBookViewController: UIHostingController<PictureBookScreen> {
    private let data: QuizInfo
    private let items: [PictureBookScreen.Item]

    init(data: QuizInfo) {
        self.data = data
        let items = data.quiz.enumerated().map { index, quiz -> PictureBookScreen.Item in
            let imageName = URL(fileURLWithPath: quiz.image).deletingPathExtension().lastPathComponent
            return PictureBookScreen.Item(
                id: index,
                imageName: imageName,
                answer: quiz.answer,
                isUnlocked: userDefault.object(forKey: quiz.image) != nil
            )
        }
        self.items = items
        super.init(rootView: PictureBookScreen(items: items, onSelect: { _ in }))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLargeTitle()
        rootView = PictureBookScreen(items: items, onSelect: { [weak self] item in
            self?.navigate(to: item)
        })
    }

    private func setupLargeTitle() {
        title = "ずかん"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(hex: "#0F9D58")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        // Shift large title to the left
        appearance.titlePositionAdjustment = UIOffset(horizontal: -(UIScreen.main.bounds.width / 2), vertical: 0)
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
    }

    private func navigate(to item: PictureBookScreen.Item) {
        let quiz = data.quiz[item.id]
        let viewModel = PictureBookDetailScreen.ViewModel(
            imageName: item.imageName,
            text: quiz.answer,
            url: URL(string: quiz.url)!
        )
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.pushViewController(PictureBookDetailViewController(viewModel: viewModel), animated: true)
    }
}
