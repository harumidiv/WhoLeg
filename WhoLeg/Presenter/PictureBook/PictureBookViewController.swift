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

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLargeTitle()

        let headerView = PictureBookTableHeaderView.loadNib()
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100)
        headerView.descriptionLabel.text = "正解した問題は名前が表示されます。 図鑑を完成を目指しましょう!!"

        tableView.tableHeaderView = headerView
    }

    private func setupLargeTitle() {
        title = "ずかん"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor(hex: "#0F9D58")
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.titlePositionAdjustment = UIOffset(horizontal: -(self.view.frame.width / 2), vertical: 0)

            // Large Title 用 NavigationBar の色設定
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            // 通常の NavigationBar の色設定
            self.navigationController?.navigationBar.standardAppearance = appearance
        }
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
        cell.quizImage?.image = UIImage(named: quizData.image)!

        if userDefault.object(forKey: quizData.image) != nil {
            cell.label?.text = quizData.answer
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            cell.tag = 1
        } else {
            cell.label.text = "? ? ?"
            cell.accessoryType = UITableViewCell.AccessoryType.none
            cell.tag = 0
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
}

extension PictureBookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quizData = data.quiz[indexPath.row]

        if tableView.cellForRow(at: indexPath)?.tag == 1 {
            let viewModel = PictureBookDetailViewController.ViewModel(image: UIImage(named: quizData.image)!, text: quizData.answer, url: URL(string: quizData.url)!)

            let vc = PictureBookDetailViewController(viewModel: viewModel)
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
