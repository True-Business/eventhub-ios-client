//
//  FriendDtos.swift
//  eventhub-ios-client
//

import Foundation

struct UserDto: Decodable {
    let id: String
    let username: String
    let shortId: String?
}

struct FindUsersRequestDto: Encodable {
    let username: String?
    let shortId: String?
    let userIdFriend: String?
    let userIdRequestTo: String?
    let userIdRequestFrom: String?
    let eventIdParticipant: String?
    let organizationIdAdmin: String?
}

struct CreateFriendRequestDto: Encodable {
    let sender: String
    let receiver: String
}

struct AcceptFriendRequestDto: Encodable {
    let requestId: String
}

struct FriendRequestDto: Decodable {
    let id: String
    let sender: String
    let receiver: String
    let status: String
}

extension UserDto {
    func toDomainUser() -> User {
        User(
            id: UUID(uuidString: id) ?? UUID(),
            name: username,
            shortId: shortId
        )
    }
}
