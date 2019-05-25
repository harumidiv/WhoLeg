//
//  WhoLegUITests.swift
//  WhoLegUITests
//
//  Created by 佐川晴海 on 2019/05/18.
//  Copyright © 2019 佐川晴海. All rights reserved.
//

import XCTest

class WhoLegUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

   
    func testExample() {
        snapshot("title")
        XCUIApplication().buttons["Button"].tap()
        let app = XCUIApplication()
        snapshot("q1")
        app.buttons["button1"].tap()
        Thread.sleep(forTimeInterval: 0.3)
        snapshot("q2")
        app.buttons["button1"].tap()
        Thread.sleep(forTimeInterval: 0.3)
        snapshot("q3")
        app.buttons["button1"].tap()
        Thread.sleep(forTimeInterval: 0.3)
        snapshot("q4")
        app.buttons["button1"].tap()
        Thread.sleep(forTimeInterval: 0.3)
        snapshot("q5")
        app.buttons["button1"].tap()
        Thread.sleep(forTimeInterval: 0.3)
        snapshot("q6")
        app.buttons["button1"].tap()
        Thread.sleep(forTimeInterval: 0.3)
        snapshot("q7")
        app.buttons["button1"].tap()
        Thread.sleep(forTimeInterval: 0.3)
        snapshot("q8")
        app.buttons["button1"].tap()
        Thread.sleep(forTimeInterval: 0.3)
        snapshot("q9")
        app.buttons["button1"].tap()
        Thread.sleep(forTimeInterval: 0.3)
        snapshot("q10")
        app.buttons["button1"].tap()
        snapshot("result")
        
        XCUIApplication().navigationBars["スコア"].buttons["Reply"].tap()
         Thread.sleep(forTimeInterval: 0.3)
        XCUIApplication().navigationBars["だれのあし？"].buttons["information"].tap()
         Thread.sleep(forTimeInterval: 0.3)
        XCUIApplication().tables/*@START_MENU_TOKEN@*/.staticTexts["ずかん"]/*[[".cells.staticTexts[\"ずかん\"]",".staticTexts[\"ずかん\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("zukan")
        
        
        
        
    }
    
    func testSnapShot(){
        
    }

}
