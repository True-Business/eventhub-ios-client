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
    let eventApi: EventApi
    let storageApi: StorageApi
    
    private init() {
        self.config = .shared
        self.authApi = AuthApiImpl(config: config)
        self.eventApi = EventApiImpl(config: config)
        self.storageApi = StorageApiImpl(config: config)
    }
}
