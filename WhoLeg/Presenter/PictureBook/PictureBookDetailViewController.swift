//
//  PictureBookDetailViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/10/13.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

class PictureBookDetailViewController: UIViewController {
    struct ViewModel {
        var image: UIImage
        var text: String
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

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: PictureBookDetailViewController.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "クイズ詳細"
    }

    @IBAction func detailTapped(_ sender: Any) {
        // TODO:
        // JSONの中にwikipediaのurlを含める
        print("aaaaa")
    }
}
