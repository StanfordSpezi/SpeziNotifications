//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions
import XCTSpeziNotifications


final class NotificationAuthorizationTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
    }

    @MainActor
    func testNotificationAuthorizationAllow() {
        let app = XCUIApplication()
        app.deleteAndLaunch(withSpringboardAppName: "TestApp")

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssert(app.navigationBars.staticTexts["Notifications"].waitForExistence(timeout: 2.0))

        XCTAssert(app.staticTexts["Authorization, notDetermined"].exists)
        XCTAssert(app.buttons["Request Authorization"].exists)
        app.buttons["Request Authorization"].tap()

        app.confirmNotificationAuthorization()

        XCTAssert(app.staticTexts["Authorization, authorized"].waitForExistence(timeout: 0.5))
    }

    @MainActor
    func testNotificationAuthorizationNotAllow() {
        let app = XCUIApplication()
        app.deleteAndLaunch(withSpringboardAppName: "TestApp")

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssert(app.navigationBars.staticTexts["Notifications"].waitForExistence(timeout: 2.0))

        XCTAssert(app.staticTexts["Authorization, notDetermined"].exists)
        XCTAssert(app.buttons["Request Authorization"].exists)
        app.buttons["Request Authorization"].tap()

        app.confirmNotificationAuthorization(action: .doNotAllow)

        XCTAssert(app.staticTexts["Authorization, denied"].waitForExistence(timeout: 0.5))
    }
}
