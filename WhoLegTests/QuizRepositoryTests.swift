//
//  TitleModelTests.swift
//  WhoLegTests
//
//  Created by しじみ100% on 2019/09/15.
//  Copyright © 2019 佐川晴海. All rights reserved.
//
@testable import WhoLeg
import XCTest

class QuizRepositoryTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJsonAnswerContain() {
        let repository = QuizRepositoryImpl()
        let quizData = repository.getJsonData()

        quizData.quiz.forEach { q in
            if q.answer == q.choice.a || q.answer == q.choice.b || q.answer == q.choice.c
                || q.answer == q.choice.d {
                XCTAssertEqual(true, true)
            } else {
                XCTAssertFalse(true)
            }
        }
    }
}
