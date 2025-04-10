//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziNotifications
import Testing
import UserNotifications


@Suite
struct NotificationsModuleUnitTestBehaviour {
    @Test
    @MainActor
    func testNotificationsModuleIsNonFunctional() async throws {
        let module = Notifications()
        try await module.setBadgeCount(12)
        try await module.add(request: UNNotificationRequest(identifier: "abc", content: UNMutableNotificationContent(), trigger: nil))
        #expect(try await module.remainingNotificationLimit() == 0)
        #expect(await module.pendingNotificationRequests() == [])
        #expect(await module.deliveredNotifications() == [])
        await module.add(categories: [UNNotificationCategory(identifier: "abc", actions: [], intentIdentifiers: [])])
        await module.removePendingNotificationRequests(where: { _ in true })
    }
}
