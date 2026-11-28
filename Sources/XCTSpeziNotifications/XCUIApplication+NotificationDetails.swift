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
    /// Assert the contents of a pending notification visualized with the `NotificationRequestView`.
    /// - Parameters:
    ///   - identifier: The identifier to assert.
    ///   - title: The title to assert.
    ///   - subtitle: The optional subtitle to assert.
    ///   - body: The body to assert.
    ///   - category: The optional category identifier to assert.
    ///   - thread: The optional thread identifier to assert.
    ///   - sound: Assert if there is sound played for the notification.
    ///   - interruption: The interruption level to assert.
    ///   - type: The trigger type to assert.
    ///   - nextTrigger: The next trigger label to assert.
    ///   - nextTriggerPrefix: A prefix of the next trigger label to assert, e.g., if the exact time is not known upfront.
    ///   - nextTriggerExistenceTimeout: The time to await for the trigger label to appear.
    public func assertNotificationDetails(
        identifier: String? = nil, // swiftlint:disable:this function_default_parameter_at_end
        title: String,
        subtitle: String? = nil, // swiftlint:disable:this function_default_parameter_at_end
        body: String,
        category: String? = nil,
        thread: String? = nil,
        sound: Bool = false,
        interruption: UNNotificationInterruptionLevel = .active,
        type: String? = nil,
        nextTrigger: String? = nil,
        nextTriggerPrefix: String? = nil,
        nextTriggerExistenceTimeout: TimeInterval = 60
    ) {
        XCTAssert(navigationBars.staticTexts[title].waitForExistence(timeout: 2.0))
        if let identifier {
            XCTAssert(staticTexts["Identifier, \(identifier)"].exists)
        }
        XCTAssert(staticTexts["Title, \(title)"].exists)
        if let subtitle {
            XCTAssert(staticTexts["Subtitle, \(subtitle)"].exists)
        }
        XCTAssert(staticTexts["Body, \(body)"].exists)
        if let category {
            XCTAssert(staticTexts["Category, \(category)"].exists)
        }
        if let thread {
            XCTAssert(staticTexts["Thread, \(thread)"].exists)
        }

        XCTAssert(staticTexts["Sound, \(sound ? "Yes" : "No")"].exists)
        XCTAssert(staticTexts["Interruption, \(interruption.description)"].exists)

        #if os(visionOS)
        staticTexts["Interruption, \(interruption.description)"].swipeUp(velocity: .fast)
        #elseif !os(tvOS)
        swipeUp()
        #endif

        if let type {
            XCTAssert(staticTexts["Type, \(type)"].waitForExistence(timeout: 2.0))
        }

        if let nextTrigger {
            XCTAssert(staticTexts["Next Trigger, \(nextTrigger)"].waitForExistence(timeout: nextTriggerExistenceTimeout))
        }

        if let nextTriggerPrefix {
            let label = staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Next Trigger, \(nextTriggerPrefix)")).firstMatch
            XCTAssert(label.waitForExistence(timeout: nextTriggerExistenceTimeout))
        }
    }

    /// Assert the contents of a pending notification visualized with the `NotificationRequestView`.
    ///
    /// Kept for binary compatibility; calls resolve to the variant that also accepts a `nextTriggerPrefix`.
    @_disfavoredOverload
    public func assertNotificationDetails(
        identifier: String? = nil, // swiftlint:disable:this function_default_parameter_at_end
        title: String,
        subtitle: String? = nil, // swiftlint:disable:this function_default_parameter_at_end
        body: String,
        category: String? = nil,
        thread: String? = nil,
        sound: Bool = false,
        interruption: UNNotificationInterruptionLevel = .active,
        type: String? = nil,
        nextTrigger: String? = nil,
        nextTriggerExistenceTimeout: TimeInterval = 60
    ) {
        assertNotificationDetails(
            identifier: identifier,
            title: title,
            subtitle: subtitle,
            body: body,
            category: category,
            thread: thread,
            sound: sound,
            interruption: interruption,
            type: type,
            nextTrigger: nextTrigger,
            nextTriggerPrefix: nil,
            nextTriggerExistenceTimeout: nextTriggerExistenceTimeout
        )
    }
}
