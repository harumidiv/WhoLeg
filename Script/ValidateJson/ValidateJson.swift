//
//  VaridateJson.swift
//  WhoLeg
//
//  Created by 佐川 晴海 on 2020/01/25.
//  Copyright © 2020 佐川晴海. All rights reserved.
//

let fileManager = FileManager.default
let path = fileManager.currentDirectoryPath
print(path)

let content = try! String(contentsOfFile: "\(path)/WhoLeg/Resource/quiz.json")

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
do {
    let quizData = try decoder.decode(QuizInfo.self, from: content.data(using: .utf8)!)

    // クイズの中に答えと選択肢で一致しないものがないかのテスト
    quizData.quiz.forEach { q in
        if q.answer == q.choice.a || q.answer == q.choice.b || q.answer == q.choice.c
            || q.answer == q.choice.d {} else {
            fatalError("【\(q.answer)】の答えが選択肢にありません！")
        }
    }
} catch {
    fatalError("Jsonの構造が壊れています")
}
