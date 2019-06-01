//
//  QuizInfo.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import Foundation

struct QuizInfo: Codable {
    var quiz: [Quiz]
}

struct Quiz: Codable {
    var image: String
    var answer: String
    var choice: Choice
}

struct Choice: Codable {
    var a: String
    var b: String
    var c: String
    var d: String
}
