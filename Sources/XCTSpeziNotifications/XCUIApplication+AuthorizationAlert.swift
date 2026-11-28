//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziNotifications
import UserNotifications
import XCTest


extension XCUIApplication {
    /// Action of the notification authorization alert.
    public enum NotificationAuthorizationAction: String {
        case allow = "Allow"
        case doNotAllow = "Don’t Allow"
    }
    
    /// Confirm the notification authorization dialog.
    ///
    /// Pass `requireAlert: false` if the alert may legitimately not show up, for example because the authorization was already decided
    /// in an earlier launch. The method then returns `false` instead of failing the test.
    ///
    /// - Parameters:
    ///   - action: The action to confirm the alert with.
    ///   - timeout: The time to wait for the alert to appear.
    ///   - requireAlert: Whether a missing alert is reported as a test failure.
    /// - Returns: `true` if the alert appeared and was confirmed.
    @available(tvOS, unavailable)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @discardableResult
    public func confirmNotificationAuthorization(
        action: NotificationAuthorizationAction = .allow,
        timeout: TimeInterval = 5.0,
        requireAlert: Bool = true
    ) -> Bool {
#if os(iOS) || os(visionOS)
        let predicate = NSPredicate(format: "label CONTAINS 'Would Like to Send You Notifications'")

    #if os(iOS)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alert = springboard.alerts.element(matching: predicate)
        let button = alert.buttons[action.rawValue]
    #else
        let notifications = XCUIApplication(bundleIdentifier: "com.apple.RealityNotifications")
        let alert = notifications.scrollViews.staticTexts.element(matching: predicate)
        let button = notifications.buttons[action.rawValue]
    #endif

        guard alert.waitForExistence(timeout: timeout) else {
            if requireAlert {
                XCTFail("The notification authorization alert did not appear within \(timeout) seconds.")
            }
            return false
        }

        XCTAssert(button.wait(for: \.isHittable, toEqual: true, timeout: 5.0))
        button.tap()
        XCTAssert(alert.waitForNonExistence(timeout: 5.0))
        return true
#else
        preconditionFailure("Unsupported platform")
#endif
    }
}
