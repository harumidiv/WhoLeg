//
//  QuizViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {
    
    private(set) lazy var myView: QuizView = QuizView()

    override func loadView() {
        view = myView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
