//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziFoundation
import SwiftUI


@MainActor
private final class RemoteNotificationContinuation: KnowledgeSource, Sendable {
    typealias Anchor = SpeziAnchor

    fileprivate(set) var continuation: CheckedContinuation<Data, Error>?
    fileprivate(set) var access = AsyncSemaphore()


    init() {}


    @MainActor
    func resume(with result: Result<Data, Error>) {
        if let continuation {
            self.continuation = nil
            access.signal()
            continuation.resume(with: result)
        }
    }
}


extension Spezi {
    /// Registers to receive remote notifications through Apple Push Notification service.
    ///
    /// Refer to the documentation of ``Spezi/registerRemoteNotifications``.
    public struct RegisterForRemoteNotificationsAction: Sendable {
        private weak var spezi: Spezi?

        fileprivate init(_ spezi: Spezi) {
            self.spezi = spezi
        }

        /// Registers to receive remote notifications through Apple Push Notification service.
        ///
        /// - Returns: A globally unique token that identifies this device to APNs.
        ///     Send this token to the server that you use to generate remote notifications.
        ///     Your server must pass this token unmodified back to APNs when sending those remote notifications.
        ///     For more information refer to the documentation of
        ///     [`application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622958-application).
        /// - Throws: Registration might fail if the user's device isn't connected to the network or
        ///     if your app is not properly configured for remote notifications. It might also throw a `TimeoutError` when running on a simulator device running on a host
        ///     that is not connected to an Apple ID.
        @discardableResult
        @MainActor
        public func callAsFunction() async throws -> Data {
            guard let spezi else {
                preconditionFailure("RegisterRemoteNotificationsAction was used in a scope where Spezi was not available anymore!")
            }

            let registration: RemoteNotificationContinuation
            if let existing = spezi.storage[RemoteNotificationContinuation.self] {
                registration = existing
            } else {
                registration = RemoteNotificationContinuation()
                spezi.storage[RemoteNotificationContinuation.self] = registration
            }

            try await registration.access.waitCheckingCancellation()

#if targetEnvironment(simulator)
            async let _ = withTimeout(of: .seconds(5)) { @MainActor in
                spezi.logger.warning("Registering for remote notifications seems to be not possible on this simulator device. Timing out ...")
                spezi.storage[RemoteNotificationContinuation.self]?.resume(with: .failure(TimeoutError()))
            }
#endif

            return try await withCheckedThrowingContinuation { continuation in
                assert(registration.continuation == nil, "continuation wasn't nil")
                registration.continuation = continuation
                _Application.shared.registerForRemoteNotifications()
            }
        }
    }

    /// Registers to receive remote notifications through Apple Push Notification service.
    ///
    /// For more information refer to the [`registerForRemoteNotifications()`](https://developer.apple.com/documentation/uikit/uiapplication/1623078-registerforremotenotifications)
    /// documentation for `UIApplication` or for the respective equivalent for your current platform.
    ///
    /// - Note: For more information on the general topic on how to register your app with APNs,
    ///     refer to the [Registering your app with APNs](https://developer.apple.com/documentation/usernotifications/registering-your-app-with-apns)
    ///     article.
    ///
    /// Below is a short code example on how to use this action within your ``Module``.
    ///
    /// - Warning: Registering for Remote Notifications on Simulator devices might not be possible if your are not signed into an Apple ID on the host machine.
    ///     The method might throw a [`TimeoutError`](https://swiftpackageindex.com/stanfordspezi/spezifoundation/documentation/spezifoundation/timeouterror)
    ///     in such a case.
    ///
    /// ```swift
    /// import SpeziFoundation
    ///
    /// class ExampleModule: Module {
    ///     @Application(\.registerRemoteNotifications)
    ///     var registerRemoteNotifications
    ///
    ///     func handleNotificationsPermissions() async throws {
    ///         // Make sure to request notifications permissions before registering for remote notifications
    ///         try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    ///
    ///
    ///         do {
    ///             let deviceToken = try await registerRemoteNotifications()
    ///         } catch let error as TimeoutError {
    /// #if targetEnvironment(simulator)
    ///             return // override logic when running within a simulator
    /// #else
    ///             throw error
    /// #endif
    ///         }
    ///
    ///         // .. send the device token to your remote server that generates push notifications
    ///     }
    /// }
    /// ```
    ///
    /// > Tip: Make sure to request authorization by calling [`requestAuthorization(options:completionHandler:)`](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/requestauthorization(options:completionhandler:))
    ///     to have your remote notifications be able to display alerts, badges or use sound. Otherwise, all remote notifications will be delivered silently.
    ///
    /// ## Topics
    /// ### Action
    /// - ``RegisterRemoteNotificationsAction``
    public var registerRemoteNotifications: RegisterForRemoteNotificationsAction {
        RegisterForRemoteNotificationsAction(self)
    }
}


extension Spezi.RegisterForRemoteNotificationsAction {
    @MainActor
    static func handleDeviceTokenUpdate(_ spezi: Spezi, _ deviceToken: Data) {
        guard let registration = spezi.storage[RemoteNotificationContinuation.self] else {
            return
        }

        // might also be called if, e.g., app is restored from backup and is automatically registered for remote notifications.
        // This can be handled through the `NotificationHandler` protocol.

        registration.resume(with: .success(deviceToken))
    }

    @MainActor
    static func handleFailedRegistration(_ spezi: Spezi, _ error: Error) {
        guard let registration = spezi.storage[RemoteNotificationContinuation.self] else {
            return
        }

        if registration.continuation == nil {
            spezi.logger.warning("Received a call to \(#function) while we were not waiting for a notifications registration request.")
        }

        registration.resume(with: .failure(error))
    }
}