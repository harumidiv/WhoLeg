//
//  ResultPresenter.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/21.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import Foundation

protocol ResultPresenter {
    func getjson() -> QuizInfo
}

class ResultPresenterImpl: ResultPresenter {
    let model: ResultModel
    init(model: ResultModel) {
        self.model = model
    }
    func getjson() -> QuizInfo {
        return model.getJson()
    }
}
