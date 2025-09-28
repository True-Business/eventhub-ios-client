//
//  ApiProvider.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 27.09.2025.
//
import Foundation

class ApiProvider {
    static let shared = ApiProvider()
    private let config: AlamofireConfig
    
    let authApi: AuthApi
    // let eventApi: EventApi
    
    private init() {
        self.config = .shared
        self.authApi = AuthApiImpl(config: config)
        // self.eventApi = EventApiImpl(config: config)
    }
}
