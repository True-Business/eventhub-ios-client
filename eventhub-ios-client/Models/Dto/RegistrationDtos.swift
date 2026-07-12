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

struct LoginUserDto: Decodable {
    let id: String
    let username: String
    let shortId: String
    let bio: String?
    let registrationDate: String?
    let isConfirmed: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case shortId
        case bio
        case registrationDate
        case isConfirmed
        case confirmed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        shortId = try container.decode(String.self, forKey: .shortId)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        registrationDate = try container.decodeIfPresent(String.self, forKey: .registrationDate)
        isConfirmed = try container.decodeIfPresent(Bool.self, forKey: .isConfirmed)
            ?? container.decodeIfPresent(Bool.self, forKey: .confirmed)
            ?? false
    }
}
 
enum RegistrationStatus: String, Codable {
    case pending = "PENDING"
    case success = "SUCCESS"
    case error   = "ERROR"
}
