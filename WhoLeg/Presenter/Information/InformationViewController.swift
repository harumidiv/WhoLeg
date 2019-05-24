//
//  InformationViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/24.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

enum PageType {
    case PictureBook
    case AppAbout
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
    
    let information:[InformationData] = [
        InformationData(label: "ずかん", pageType:.PictureBook),
        InformationData(label: "このアプリについて", pageType: .AppAbout)
    ]
    let jsonData:QuizInfo
    
    init(data: QuizInfo) {
        self.jsonData = data
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
        return cell
    }
}

extension InformationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let data = information[indexPath.row]
        switch data.pageType {
        case .PictureBook:
            self.navigationController?.pushViewController(PictureBookViewController(data: jsonData), animated: true)
        case .AppAbout:
            self.navigationController?.pushViewController(AppAboutViewController(), animated: true)
        }
    }
}

