//
//  TitlePresenter.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/20.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import Foundation

protocol TitlePresenter {
    func getJsonData() -> QuizInfo
}

class TitlePresenterImpl: TitlePresenter {
    private var model: TitleModel

    init(model: TitleModel) {
        self.model = model
    }

    func getJsonData() -> QuizInfo {
        return model.getQuizJson()
    }
}
