//
//  AlamofireConfig.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import Foundation
import Alamofire

class AlamofireConfig {
    static let shared = AlamofireConfig()
    
    private let baseURL = "http://eventhub-backend.ru/prod/"
    private let session: Session
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        session = Session(configuration: configuration)
    }
    
    func makeSession() -> Session {
        return session
    }
    
    func getBaseUrl() -> String {
        return baseURL
    }
}

