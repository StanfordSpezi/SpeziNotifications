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
        XCTAssert(app.navigationBars.staticTexts["Notifications"].waitForExistence(timeout: 10.0))

        XCTAssert(app.staticTexts["Authorization, notDetermined"].waitForExistence(timeout: 5.0))
        XCTAssert(app.buttons["Request Authorization"].wait(for: \.isHittable, toEqual: true, timeout: 5.0))
        app.buttons["Request Authorization"].tap()

        app.confirmNotificationAuthorization()

        XCTAssert(app.staticTexts["Authorization, authorized"].waitForExistence(timeout: 5.0))
    }

    @MainActor
    func testNotificationAuthorizationNotAllow() {
        let app = XCUIApplication()
        app.deleteAndLaunch(withSpringboardAppName: "TestApp")

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssert(app.navigationBars.staticTexts["Notifications"].waitForExistence(timeout: 10.0))

        XCTAssert(app.staticTexts["Authorization, notDetermined"].waitForExistence(timeout: 5.0))
        XCTAssert(app.buttons["Request Authorization"].wait(for: \.isHittable, toEqual: true, timeout: 5.0))
        app.buttons["Request Authorization"].tap()

        app.confirmNotificationAuthorization(action: .doNotAllow)

        XCTAssert(app.staticTexts["Authorization, denied"].waitForExistence(timeout: 5.0))
    }

    @MainActor
    func testNotificationAuthorizationAlreadyDetermined() {
        let app = XCUIApplication()
        app.deleteAndLaunch(withSpringboardAppName: "TestApp")

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssert(app.buttons["Request Authorization"].wait(for: \.isHittable, toEqual: true, timeout: 10.0))
        app.buttons["Request Authorization"].tap()

        XCTAssertTrue(app.confirmNotificationAuthorization())
        XCTAssert(app.staticTexts["Authorization, authorized"].waitForExistence(timeout: 5.0))

        // Authorization is already determined, so no alert shows up a second time.
        XCTAssertFalse(app.confirmNotificationAuthorization(timeout: 2.0, requireAlert: false))
        _ = XCTExpectFailure("A missing alert fails the test if it is required") {
            app.confirmNotificationAuthorization(timeout: 2.0)
        }
    }
}
