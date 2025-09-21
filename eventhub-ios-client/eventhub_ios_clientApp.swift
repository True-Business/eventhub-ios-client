//
//  eventhub_ios_clientApp.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//

import SwiftUI

@main
struct eventhub_ios_clientApp: App {
    
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            WelcomePage()
                .environmentObject(authViewModel)
        }
    }
}
