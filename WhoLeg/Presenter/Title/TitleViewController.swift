//
//  TitleViewController.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {

    @IBOutlet weak var image: RoundImage!
    @IBOutlet weak var label: UILabel!
    private var presenter: TitlePresenter!
    
    var jsonData: QuizInfo!
    
    func injector(presenter: TitlePresenter){
        self.presenter = presenter
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "だれのあし？"
        self.navigationItem.hidesBackButton = true
        jsonData = presenter.getJsonData()
        
        let rand = Int.random(in: 0..<jsonData.quiz.count)
        image.image = UIImage(named: jsonData.quiz[rand].image)
        label.text = jsonData.quiz[rand].answer
        
        let informationButton: UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "information") , style: .plain, target: self, action: #selector(showInformation(_:)))
        navigationItem.rightBarButtonItem = informationButton
    }

    // MAKR: - Event
    
    @objc func showInformation(_ sender: UIBarButtonItem) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(InformationViewController(data: jsonData), animated: true)
    }
    
    @IBAction func quizStart(_ sender: Any) {
        let quizViewController = QuizViewController(quizData: jsonData, score: 0, count: 1)
        quizViewController.injector(presenter: QuizPresenterImpl(model: QuizModelImpl(), output: quizViewController), wireframe: QuizWireframeImpl())
        self.navigationController?.pushViewController(quizViewController, animated: true)
    }
}
