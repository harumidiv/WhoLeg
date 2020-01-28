//
//  VaridateJson.swift
//  WhoLeg
//
//  Created by 佐川 晴海 on 2020/01/25.
//  Copyright © 2020 佐川晴海. All rights reserved.
//

print("hello shellScript")

let fileManager = FileManager.default
let path = fileManager.currentDirectoryPath
print(path)

let content = try! String(contentsOfFile: "\(path)/WhoLeg/Resource/quiz.json")

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
do {
    _ = try decoder.decode(QuizInfo.self, from: content.data(using: .utf8)!)
} catch {
    fatalError("Local Json Parse Error")
}
