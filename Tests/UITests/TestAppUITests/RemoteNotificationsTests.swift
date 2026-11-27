//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


final class RemoteNotificationsTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
    }

    @MainActor
    func testRegistrationOnSimulator() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssertTrue(app.navigationBars.staticTexts["Notifications"].waitForExistence(timeout: 10.0))
        XCTAssertTrue(app.staticTexts["Token, none"].exists)
        XCTAssertTrue(app.buttons["Register"].exists)
        XCTAssertTrue(app.buttons["Unregister"].exists)

        app.buttons["Register"].tap()

        // Registration either yields a token or times out on the simulator; both are acceptable, a failure is not.
        let outcomes = ["Token, 80 bytes", "Token, 60 bytes", "Token, Timeout"]
        let settled = NSPredicate(format: "label IN %@", outcomes)
        XCTAssertTrue(app.staticTexts.matching(settled).firstMatch.waitForExistence(timeout: 15.0))
        XCTAssertFalse(app.staticTexts["Token, failed"].exists)

        // the unit test accepts both success and failure states. Therefore, print the content of the field to have it visible in the logs
        print("Read token field as: \(app.staticTexts.matching(identifier: "token-field").firstMatch.debugDescription)")

        app.buttons["Unregister"].tap()
        XCTAssertTrue(app.staticTexts["Token, none"].waitForExistence(timeout: 5.0))
    }
}
