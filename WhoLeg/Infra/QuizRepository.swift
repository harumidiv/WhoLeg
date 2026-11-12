//
//  QuizRepository.swift
//  WhoLeg
//
//  Created by 佐川晴海 on 2019/05/21.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import Foundation

protocol QuizRepository {
    func getJsonData() -> QuizInfo
}

class QuizRepositoryImpl: QuizRepository {
    func getJsonData() -> QuizInfo {
        let path: String = Bundle.main.path(forResource: "Resource/quiz", ofType: "json")!
        var jsonData: QuizInfo!
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            jsonData = try JSONDecoder().decode(QuizInfo.self, from: content.data(using: .utf8)!)
            return QuizLocalizer.localize(jsonData)
        } catch {
            // TODO: Error handling
            return jsonData
        }
    }
}

/// quiz.json は日本語で書かれているので、端末の言語に合わせて答えと選択肢を翻訳する。
/// 翻訳は Animals.xcstrings（日本語のなまえがキー）にまとめてある。
/// 正解の記録は画像名をキーにしているので、言語を変えても集めたずかんはそのまま残る
enum QuizLocalizer {
    static func localize(_ info: QuizInfo, bundle: Bundle = .main) -> QuizInfo {
        let language = bundle.preferredLocalizations.first ?? "ja"
        // 日本語ならそのまま（元のWikipediaのリンクも使える）
        guard language != "ja" else { return info }

        func name(_ japanese: String) -> String {
            bundle.localizedString(forKey: japanese, value: japanese, table: "Animals")
        }

        var info = info
        info.quiz = info.quiz.map { quiz in
            var quiz = quiz
            quiz.answer = name(quiz.answer)
            quiz.choice = Choice(
                a: name(quiz.choice.a),
                b: name(quiz.choice.b),
                c: name(quiz.choice.c),
                d: name(quiz.choice.d)
            )
            quiz.url = wikipediaSearchURL(for: quiz.answer, language: language)?.absoluteString ?? quiz.url
            return quiz
        }
        return info
    }

    /// その言語のWikipediaで名前を検索するURL。記事がぴったり見つかればそのまま記事が開く
    static func wikipediaSearchURL(for name: String, language: String) -> URL? {
        let host: String
        var variant: String?
        switch language {
        case "zh-Hans":
            host = "zh"
            variant = "zh-cn"
        case "zh-Hant":
            host = "zh"
            variant = "zh-tw"
        default:
            // pt-BR → pt のように、地域を外した言語コードがWikipediaのサブドメインになる
            host = String(language.prefix { $0 != "-" })
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(host).wikipedia.org"
        components.path = "/w/index.php"
        components.queryItems = [URLQueryItem(name: "search", value: name)]
        if let variant {
            components.queryItems?.append(URLQueryItem(name: "variant", value: variant))
        }
        return components.url
    }
}
