//
//  FriendsViewModel.swift
//  eventhub-ios-client
//

import Foundation

final class FriendsViewModel: ObservableObject {
    @Published var friends: [User] = []
    @Published var searchResults: [User] = []
    @Published var searchMode: UserSearchMode = .username
    @Published var incomingRequests: [FriendRequest] = []
    @Published var isLoadingFriends = false
    @Published var isLoadingIncomingRequests = false
    @Published var isSearching = false
    @Published var pendingRequestUserIds: Set<UUID> = []
    @Published var pendingIncomingRequestIds: Set<UUID> = []
    @Published var sentRequestUserIds: Set<UUID> = []
    @Published var errorMessage: String?

    private let repository: FriendsRepository
    private var activeSearchRequestId: UUID?

    init(repository: FriendsRepository = FriendsRepository()) {
        self.repository = repository
    }

    func loadFriends(userId: String?) {
        guard let userId = userId.flatMap(UUID.init(uuidString:)), !isLoadingFriends else {
            return
        }

        isLoadingFriends = true
        errorMessage = nil

        repository.fetchFriends(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingFriends = false

                switch result {
                case .success(let friends):
                    self?.friends = friends
                case .failure(let error):
                    self?.friends = []
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func loadIncomingRequests(userId: String?) {
        guard let userId = userId.flatMap(UUID.init(uuidString:)), !isLoadingIncomingRequests else {
            return
        }

        isLoadingIncomingRequests = true
        errorMessage = nil

        repository.fetchIncomingRequests(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingIncomingRequests = false

                switch result {
                case .success(let requests):
                    self?.incomingRequests = requests
                case .failure(let error):
                    self?.incomingRequests = []
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func searchUsers(query: String, currentUserId: String?) {
        let query = query.trimmed
        guard query.count >= 2 else {
            searchResults = []
            activeSearchRequestId = nil
            return
        }

        isSearching = true
        errorMessage = nil
        let currentUserUUID = currentUserId.flatMap(UUID.init(uuidString:))
        let searchRequestId = UUID()
        activeSearchRequestId = searchRequestId

        repository.searchUsers(query: query, mode: searchMode, currentUserId: currentUserUUID) { [weak self] result in
            DispatchQueue.main.async {
                guard self?.activeSearchRequestId == searchRequestId else {
                    return
                }

                self?.isSearching = false

                switch result {
                case .success(let users):
                    let friendIds = Set(self?.friends.map(\.id) ?? [])
                    self?.searchResults = users.filter { !friendIds.contains($0.id) }
                case .failure(let error):
                    self?.searchResults = []
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func clearSearch() {
        searchResults = []
        activeSearchRequestId = nil
        errorMessage = nil
    }

    func toggleSearchMode(query: String, currentUserId: String?) {
        searchMode = searchMode == .username ? .shortId : .username
        searchUsers(query: query, currentUserId: currentUserId)
    }

    func sendFriendRequest(to user: User, currentUserId: String?) {
        guard let senderId = currentUserId.flatMap(UUID.init(uuidString:)) else {
            errorMessage = "Не удалось определить пользователя"
            return
        }

        guard !pendingRequestUserIds.contains(user.id), !sentRequestUserIds.contains(user.id) else {
            return
        }

        pendingRequestUserIds.insert(user.id)
        errorMessage = nil

        repository.sendFriendRequest(senderId: senderId, receiverId: user.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.pendingRequestUserIds.remove(user.id)

                switch result {
                case .success:
                    self?.sentRequestUserIds.insert(user.id)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func acceptIncomingRequest(_ request: FriendRequest, currentUserId: String?) {
        guard !pendingIncomingRequestIds.contains(request.id) else {
            return
        }

        pendingIncomingRequestIds.insert(request.id)
        errorMessage = nil

        repository.acceptFriendRequest(requestId: request.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.pendingIncomingRequestIds.remove(request.id)

                switch result {
                case .success:
                    self?.incomingRequests.removeAll { $0.id == request.id }
                    self?.loadFriends(userId: currentUserId)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func rejectIncomingRequest(_ request: FriendRequest) {
        guard !pendingIncomingRequestIds.contains(request.id) else {
            return
        }

        pendingIncomingRequestIds.insert(request.id)
        errorMessage = nil

        repository.rejectFriendRequest(requestId: request.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.pendingIncomingRequestIds.remove(request.id)

                switch result {
                case .success:
                    self?.incomingRequests.removeAll { $0.id == request.id }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
