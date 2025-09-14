//
//  eventhub_ios_clientApp.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//

import SwiftUI

@main
struct eventhub_ios_clientApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomePage(authViewModel: AuthViewModel())
        }
    }
}
