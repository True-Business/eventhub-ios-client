//
//  RegistrationDtos.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 27.09.2025.
//

struct UserCredentialsRegistrationDto: Codable {
    let email: String
    let password: String
}

struct UserInfoRegistrationDto: Codable {
    let id: String
    let username: String
    let shortId: String
}

struct RegistrationResponseDto: Codable {
    let id: String
    let registrationDate: String?
    let status: String
    let reason: String?
}
 
enum RegistrationStatus: String, Codable {
    case pending = "PENDING"
    case success = "SUCCESS"
    case error   = "ERROR"
}

