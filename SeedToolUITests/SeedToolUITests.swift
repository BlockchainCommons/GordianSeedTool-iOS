//
//  SeedToolUITests.swift
//  SeedToolUITests
//
//  Created by Wolf McNally on 2/28/21.
//

import XCTest

enum ScenicView: Int {
    case seedList
    case docs
    case addSeed
    case playingCards
    case seedDetail
    case deriveKey1
    case deriveKey2
    case exportKey

    var name: String {
        "\(rawValue)\(self)"
    }
}

class SeedToolUITests: XCTestCase {
    let app = XCUIApplication()

    //
    // This test will FAIL if the iOS simulator has "Connect Hardware Keyboard" on.
    //
    
    func testScreenShots() throws {
        launch()
        try acceptLicense()

        try setupSampleData()

        try visitDocs {
            try tap("What is a Seed?")
            scenicView(.docs)
        }

        try visitAddSeed {
            scenicView(.addSeed)

            try visitPlayingCards {
                try tap("Random All")
                scenicView(.playingCards)
            }
        }
        
        try visitSeed(name: "Spacely Sprockets") {
            tapButtonCoord("Authenticate")
            scenicView(.seedDetail)

            try visitDeriveKey {
                scenicView(.deriveKey1)
                app.swipeUp(velocity: .fast)
                scenicView(.deriveKey2)
                try visitShareKey {
                    scenicView(.exportKey)
                }
            }
        }
    }
    
    func tapButtonCoord(_ name: String) {
        let button = app.buttons[name]
        let c1 = button.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let c2 = c1.withOffset(CGVector(dx: 10, dy: 10))
        sleep(1)
        c2.tap()
        // app.buttons["Authenticate"].tap()
        // try tap("Authenticate")
    }

    func visitDocs(action: () throws -> Void) throws {
        sleep(2)
        try tap("Documentation")
        try action()
        try tapDone()
    }

    func visitPlayingCards(action: () throws -> Void) throws {
        try tap("Playing Cards")
        try action()
        try tap("Cancel Import")
    }

    func visitAddSeed(action: () throws -> Void) throws {
        iPadShowSeedsSidebar()
        scenicView(.seedList)
        try tapAddSeed()
        try action()
        try tap("Cancel Add Seed")
    }

    func visitDeriveKey(action: () throws -> Void) throws {
        try tap("Derive Key Menu")
        try tap("Other Key Derivations")
        try action()
        app.swipeDown(velocity: .fast)
        app.swipeDown(velocity: .fast)
        if app.buttons["Export Done"].exists {
            try tap("Export Done")
        }
    }

    func visitShareKey(action: () throws -> Void) throws {
        try tap("Share Private")
        try action()
        try tapDone()
    }

    func tap(_ name: String) throws {
        if !app.buttons[name].isHittable {
            app.swipeUp(velocity: .slow)
        }
        try app.buttons[name].waitThenTap()
    }

    func tapDone() throws {
        try app.buttons["Done"].waitThenTap()
    }

    func setupSampleData() throws {
        try eraseAllData()
        try addSeed(dieRolls: ["3", "4", "5", "6"], name: "Personal", note: "")
        try addSeed(dieRolls: ["5", "6", "1", "2"], name: "Spacely Sprockets", note: "Use only on authorization of Cosmo Spacely.")
        try addSeed(dieRolls: ["1", "2", "3", "4"], name: "Planet Express", note: "Use only on authorization of Hubert Farnsworth.")
    }

    func scenicView(_ scenicView: ScenicView) {
        print("🖼 \(scenicView.name)")
        snapshot(scenicView.name)
        //sleep(5)
    }

    func launch() {
        app.launchArguments.append("SNAPSHOT")
        setupSnapshot(app)
        app.launch()
        app.activate()
    }

    func eraseAllData() throws {
        try tap("Settings")
        try tap("Ethereum")
        try tap("Erase All Data")
        try tap("Erase")
    }

    func acceptLicense() throws {
        if app.buttons["I Accept"].exists {
            try tap("I Accept")
        }
    }

    func iPadShowSeedsSidebar() {
        if !app.buttons["Add Seed"].isHittable && app.buttons["Seeds"].isHittable {
            app.buttons["Seeds"].tap()
        }
    }

    func tapAddSeed() throws {
        iPadShowSeedsSidebar()
        try tap("Add Seed")
    }

    func addSeed(dieRolls: [String], name: String, note: String) throws {
        try tapAddSeed()

        if !app.buttons["Die Rolls"].isHittable {
            app.swipeUp(velocity: .slow)
        }
        try tap("Die Rolls")

        app.tapSequence(dieRolls)
        try app.navigationBars["Die Rolls"].buttons["Done"].waitThenTap()
        try app.alerts["Weak Entropy"].scrollViews.otherElements.buttons["Continue"].waitThenTap()

        if !app.textFields["Name Field"].isHittable {
            app.swipeUp(velocity: .slow)
        }

        app.textFields["Name Field"].clearField(typing: name)
        if !note.isEmpty {
            let notesTextEditor = app.scrollViews.otherElements.textViews["Notes Field"]
            UIPasteboard.general.string = note
            notesTextEditor.tap()
            notesTextEditor.tap()
            app.staticTexts["Paste"].tap()
        }
        sleep(2)
        try tap("Save")
    }

    func visitSeed(name: String, action: () throws -> Void) throws {
        iPadShowSeedsSidebar()
        try tap("Seed: \(name)")
        try action()
        try tap("Seeds")
    }
}

extension XCUIApplication {
    func tapSequence(_ sequence: [String]) {
        for s in sequence {
            self.buttons[s].tap()
        }
    }
}

extension XCUIElement {
    func waitThenTap() throws {
        guard self.waitForExistence(timeout: 10) else {
            XCTFail("Couldn't find element.")
            throw NSError()
        }
        self.firstMatch.tap()
    }

    func forceTap() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx:0.0, dy:0.0))
            coordinate.tap()
        }
    }

    func clearField() {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        focusField()
        if !stringValue.isEmpty {
            self.tap()
            XCUIApplication().staticTexts["Select All"].tap()
            XCUIApplication().staticTexts["Cut"].tap()
            sleep(1)
        }
        focusField()
        focusField()
    }

    func clearField(typing text: String) {
        clearField()
        typeText("\(text)\n")
        sleep(1)
    }

    func focusField() {
        if !self.isFocused {
            self.tap()
            sleep(1)
        }
    }

    var isFocused: Bool {
        let isFocused = (self.value(forKey: "hasKeyboardFocus") as? Bool) ?? false
        return isFocused
    }
}
