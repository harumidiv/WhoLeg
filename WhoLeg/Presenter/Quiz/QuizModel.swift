//
//  QuizModel.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/19.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import Foundation

protocol QuizModel {
    func stringComParison(lhs: String, rhs: String) -> Bool
    func createRandomElement(a: String, b: String, c: String, d: String) -> [String]
}

class QuizModelImpl: QuizModel {
    func createRandomElement(a: String, b: String, c: String, d: String) -> [String] {
        let arr = [a, b, c, d]
        return arr.shuffled()
    }
    
    
    func stringComParison(lhs: String, rhs: String) -> Bool {
        if lhs == rhs {
            return true
        }
        return false
    }
}
