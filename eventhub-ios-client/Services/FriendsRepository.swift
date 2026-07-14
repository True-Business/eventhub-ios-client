//
//  FriendsRepository.swift
//  eventhub-ios-client
//

import Foundation

enum UserSearchMode {
    case username
    case shortId

    var title: String {
        switch self {
        case .username:
            return "Имя"
        case .shortId:
            return "@"
        }
    }
}

final class FriendsRepository {
    private let friendsApi: FriendsApi

    init(friendsApi: FriendsApi = ApiProvider.shared.friendsApi) {
        self.friendsApi = friendsApi
    }

    func fetchFriends(userId: UUID, completion: @escaping (Result<[User], Error>) -> Void) {
        friendsApi.getFriends(userId: userId) { result in
            completion(result.map { $0.map { $0.toDomainUser() } }.mapError { $0 })
        }
    }

    func fetchIncomingRequests(userId: UUID, completion: @escaping (Result<[FriendRequest], Error>) -> Void) {
        friendsApi.getIncomingRequests(userId: userId) { result in
            switch result {
            case .success(let requestDtos):
                self.fetchSenders(for: requestDtos, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func searchUsers(
        query: String,
        mode: UserSearchMode,
        currentUserId: UUID?,
        completion: @escaping (Result<[User], Error>) -> Void
    ) {
        let cleanQuery = query.trimmed
        let shortId = cleanQuery.hasPrefix("@") ? String(cleanQuery.dropFirst()) : cleanQuery
        let filter = FindUsersRequestDto(
            username: mode == .username ? cleanQuery : nil,
            shortId: mode == .shortId ? shortId : nil,
            userIdFriend: nil,
            userIdRequestTo: nil,
            userIdRequestFrom: nil,
            eventIdParticipant: nil,
            organizationIdAdmin: nil
        )

        friendsApi.searchUsers(filter: filter) { result in
            completion(
                result.map { users in
                    users
                        .map { $0.toDomainUser() }
                        .filter { $0.id != currentUserId }
                }
                .mapError { $0 }
            )
        }
    }

    func sendFriendRequest(senderId: UUID, receiverId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        let dto = CreateFriendRequestDto(sender: senderId.uuidString, receiver: receiverId.uuidString)

        friendsApi.sendFriendRequest(dto: dto) { result in
            completion(result.map { _ in () }.mapError { $0 })
        }
    }

    func acceptFriendRequest(requestId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        let dto = AcceptFriendRequestDto(requestId: requestId.uuidString)

        friendsApi.acceptFriendRequest(dto: dto) { result in
            completion(result.mapError { $0 })
        }
    }

    func rejectFriendRequest(requestId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        friendsApi.rejectFriendRequest(requestId: requestId) { result in
            completion(result.mapError { $0 })
        }
    }

    private func fetchSenders(
        for requestDtos: [FriendRequestDto],
        completion: @escaping (Result<[FriendRequest], Error>) -> Void
    ) {
        guard !requestDtos.isEmpty else {
            completion(.success([]))
            return
        }

        let group = DispatchGroup()
        let lock = NSLock()
        var requests: [FriendRequest] = []
        var firstError: Error?

        for dto in requestDtos {
            guard
                let requestId = UUID(uuidString: dto.id),
                let senderId = UUID(uuidString: dto.sender)
            else {
                continue
            }

            group.enter()
            friendsApi.getUser(userId: senderId) { result in
                lock.lock()
                switch result {
                case .success(let userDto):
                    requests.append(FriendRequest(id: requestId, sender: userDto.toDomainUser()))
                case .failure(let error):
                    if firstError == nil {
                        firstError = error
                    }
                }
                lock.unlock()
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let firstError {
                completion(.failure(firstError))
            } else {
                completion(.success(requests))
            }
        }
    }
}

struct FriendRequest: Identifiable {
    let id: UUID
    let sender: User
}
