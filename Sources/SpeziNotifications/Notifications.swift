//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
@preconcurrency import UserNotifications


/// Interact with local notifications.
///
/// This module provides some easy to use API to schedule and manage local notifications.
///
/// ## Topics
///
/// ### Configuration
/// - ``init()``
///
/// ### Badge Count
/// - ``setBadgeCount(isolation:_:)``
///
/// ### Add a Notification Request
/// - ``add(isolation:request:)``
///
/// ### Notification Limits
/// - ``pendingNotificationsLimit``
/// - ``remainingNotificationLimit(isolation:)``
///
/// ### Fetching Notifications
/// - ``pendingNotificationRequests(isolation:)``
/// - ``deliveredNotifications(isolation:)``
///
/// ### Categories
/// - ``add(isolation:categories:)``
public final class Notifications: Module, DefaultInitializable, EnvironmentAccessible {
    /// The total limit of simultaneously scheduled notifications.
    ///
    /// The limit is `64`.
    public static let pendingNotificationsLimit = 64

    @Application(\.notificationSettings)
    public var notificationSettings

    @Application(\.requestNotificationAuthorization)
    public var requestNotificationAuthorization
    
    private let notificationCenter: UNUserNotificationCenter

    /// Configure the local notifications module.
    public init() {
        notificationCenter = .current()
    }

    /// Updates the badge count for your app’s icon.
    /// - Parameters:
    ///   - isolation: Inherits the current isolation.
    ///   - badgeCount: The new badge count to display.
    @available(watchOS, unavailable)
    public func setBadgeCount(
        isolation: isolated (any Actor)? = #isolation,
        _ badgeCount: Int
    ) async throws {
        try await notificationCenter.setBadgeCount(badgeCount)
    }

    /// Schedule a new notification request.
    /// - Parameters:
    ///   - isolation: Inherits the current isolation.
    ///   - request: The notification request.
    public func add(
        isolation: isolated (any Actor)? = #isolation,
        request: UNNotificationRequest
    ) async throws {
        print("Adding Notification Request: \(request)")
        try await notificationCenter.add(request)
    }

    /// Retrieve the amount of notifications that can be scheduled for the app.
    ///
    /// An application has a total limit of ``pendingNotificationsLimit`` that can be scheduled (pending). This method retrieve the reaming notifications that can be scheduled.
    ///
    /// - Note: Already delivered notifications do not count towards this limit.
    /// - Parameter isolation: Inherits the current isolation.
    /// - Returns: Returns the remaining amount of notifications that can be scheduled for the application.
    public func remainingNotificationLimit(isolation: isolated (any Actor)? = #isolation) async -> Int {
        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        return max(0, Self.pendingNotificationsLimit - pendingRequests.count)
    }

    /// Fetch all notification requests that are pending delivery.
    /// - Parameter isolation: Inherits the current isolation.
    /// - Returns: The array of pending notifications requests.
    public func pendingNotificationRequests(isolation: isolated (any Actor)? = #isolation) async -> sending [UNNotificationRequest] {
        await notificationCenter.pendingNotificationRequests()
    }

    /// Fetch all delivered notifications that are still shown in the notification center.
    /// - Parameter isolation: Inherits the current isolation.
    /// - Returns: The array of local and remote notifications that have been delivered and are still show in the notification center.
    @available(tvOS, unavailable)
    public func deliveredNotifications(isolation: isolated (any Actor)? = #isolation) async -> sending [UNNotification] {
        await notificationCenter.deliveredNotifications()
    }

    /// Add additional notification categories.
    ///
    /// This method adds additional notification categories. Call this method within your configure method of your Module to ensure that categories are configured
    /// as early as possible.
    ///
    /// To receive the action that are performed for your category, implement the ``NotificationHandler/handleNotificationAction(_:)`` method of the
    /// ``NotificationHandler`` protocol.
    ///
    /// - Note: Aim to only call this method once at startup.
    ///
    /// - Parameters:
    ///   - isolation: Inherits the current isolation.
    ///   - categories: The notification categories you support.
    @available(tvOS, unavailable)
    public func add(
        isolation: isolated (any Actor)? = #isolation,
        categories: Set<UNNotificationCategory>
    ) async {
        let previousCategories = await notificationCenter.notificationCategories()
        notificationCenter.setNotificationCategories(categories.union(previousCategories))
    }
    
    
    /// Removes all pending notification requests that satisfy the predicate.
    public func removePendingNotificationRequests(
        isolation: isolated (any Actor)? = #isolation,
        where predicate: (UNNotificationRequest) -> Bool
    ) async {
        let identifiers = await notificationCenter.pendingNotificationRequests().compactMap { request in
            predicate(request) ? request.identifier : nil
        }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
