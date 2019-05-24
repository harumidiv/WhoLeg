//
//  PictureBookViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/24.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

class PictureBookViewController: UIViewController {

    let data: QuizInfo
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(cellType: PictureBookTableViewCell.self)
        }
    }
    // MARK: - Initializer
    init(data: QuizInfo) {
        self.data = data
        super.init(nibName: String(describing: PictureBookViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


extension PictureBookViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.quiz.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let quizData = data.quiz[indexPath.row]
        let cell = tableView.dequeueReusableCell(with: PictureBookTableViewCell.self, for: indexPath)
        cell.selectionStyle = .none
        cell.quizImage?.image = UIImage(named:quizData.image)!
        
        if userDefault.object(forKey: quizData.image) != nil {
            cell.label?.text = quizData.answer
        } else {
            cell.label.text = "? ? ?"
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
}

extension PictureBookViewController: UITableViewDelegate {}
