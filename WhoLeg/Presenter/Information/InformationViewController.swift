//
//  InformationViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/24.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

enum PageType {
    case pictureBook
    case appAbout
}

struct InformationData {
    var label: String
    var pageType: PageType
}

class InformationViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        }
    }

    let information: [InformationData] = [
        InformationData(label: "ずかん", pageType: .pictureBook),
        InformationData(label: "このアプリについて", pageType: .appAbout)
    ]
    let jsonData: QuizInfo

    init(data: QuizInfo) {
        jsonData = data
        super.init(nibName: String(describing: InformationViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }

    override func viewDidLoad() {
        title = "じょうほう"
        super.viewDidLoad()
    }
}

extension InformationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return information.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = information[indexPath.row].label
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }
}

extension InformationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let data = information[indexPath.row]
        switch data.pageType {
        case .pictureBook:
            navigationController?.pushViewController(PictureBookViewController(data: jsonData), animated: true)
        case .appAbout:
            navigationController?.pushViewController(AppAboutViewController(), animated: true)
        }
    }
}
