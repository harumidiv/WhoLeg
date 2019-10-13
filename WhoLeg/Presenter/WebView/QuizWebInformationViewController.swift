//
//  QuizWebInformationViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/10/13.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

class QuizWebInformationViewController: UIViewController {
    let url: URL
    init(url: URL) {
        self.url = url
        super.init(nibName: String(describing: QuizWebInformationViewController.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
    }
}
