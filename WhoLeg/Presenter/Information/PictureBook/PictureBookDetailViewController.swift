//
//  PictureBookDetailViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/10/13.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import SafariServices
import UIKit

class PictureBookDetailViewController: UIViewController {
    struct ViewModel {
        var image: UIImage
        var text: String
        var url: URL
    }

    var viewModel: ViewModel

    @IBOutlet weak var image: UIImageView! {
        didSet {
            image.image = viewModel.image
        }
    }

    @IBOutlet weak var name: UILabel! {
        didSet {
            name.text = viewModel.text
        }
    }

    @IBOutlet weak var detailButton: UIButton! {
        didSet {
            detailButton.setTitle(viewModel.text + "って何？", for: .normal)
        }
    }

    // MARK: - Initializer

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: PictureBookDetailViewController.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "クイズ詳細"
        navigationItem.largeTitleDisplayMode = .never

        // 図鑑画面でNavigationBarTitle位置をずらしたのを戻す
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(hex: "#0F9D58")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)
        navigationController?.navigationBar.standardAppearance = appearance
    }

    // MARK: - Eevnt

    @IBAction func detailTapped(_ sender: Any) {
        let vc = SFSafariViewController(url: viewModel.url)
        present(vc, animated: true, completion: nil)
    }
}
