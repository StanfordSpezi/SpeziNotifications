//
// This source file is part of the SpeziNotifications open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import SpeziNotifications


@main
struct UITestsApp: App {
    var body: some Scene {
        WindowGroup {
            Text(SpeziNotifications().stanford)
            Text(operatingSystem)
        }
    }
}
