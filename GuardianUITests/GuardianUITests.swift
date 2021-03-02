//
//  GuardianUITests.swift
//  GuardianUITests
//
//  Created by Wolf McNally on 2/28/21.
//

import XCTest

class GuardianUITests: XCTestCase {

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//
//        // In UI tests it is usually best to stop immediately when a failure occurs.
//        continueAfterFailure = false
//
//        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
//    }

//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    func test1() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
//        app.buttons["I Accept"].tap()
        app.buttons["gearshape"].tap()
        app.buttons["Erase All Data"].tap()
        app.alerts["Erase All Data"].scrollViews.otherElements.buttons["Erase"].tap()
        app.navigationBars["Seeds"].buttons["plus"].tap()
        app.tables.buttons["Die Rolls"].tap()
        app.buttons["die.face.1.fill"].tap()
        app.buttons["die.face.2.fill"].tap()
        app.buttons["die.face.3.fill"].tap()
        app.buttons["die.face.4.fill"].tap()
        app.navigationBars["Die Rolls"].buttons["Done"].tap()
        app.alerts["Weak Entropy"].scrollViews.otherElements.buttons["Continue"].tap()
        
        let nameTextField = app.scrollViews.otherElements.textFields["Name"]
        nameTextField.tap()
        nameTextField.typeText("Business Accounts")

        app.buttons["Save"].tap()

//        snapshot("0Launch")
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
