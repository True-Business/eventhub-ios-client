//
//  FriendsPage.swift
//  eventhub-ios-client
//

import SwiftUI

struct FriendsPage: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var viewModel = FriendsViewModel()
    @State private var showAddFriend = false
    @State private var showTitleMenu = false
    @State private var showRequestsDropdown = false
    @State private var searchText = ""

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.38, blue: 0.0).opacity(0.16),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            content

            if showTitleMenu {
                titleMenu
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(2)
            }

            if showRequestsDropdown {
                requestsDropdown
                    .padding(.top, 66)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(3)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button {
                    withAnimation(.easeInOut) {
                        showTitleMenu.toggle()
                        if !showTitleMenu {
                            showRequestsDropdown = false
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text("Друзья")
                            .font(.headline)
                            .foregroundColor(.primary)

                        if viewModel.incomingRequests.count > 0 {
                            BadgeView(count: viewModel.incomingRequests.count)
                        }

                        Image(systemName: showTitleMenu ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddFriend = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
        .onAppear {
            viewModel.loadFriends(userId: authViewModel.currentUserId)
            viewModel.loadIncomingRequests(userId: authViewModel.currentUserId)
        }
        .sheet(isPresented: $showAddFriend) {
            addFriendSheet
                .presentationDetents([.medium, .large])
        }
    }

    private var titleMenu: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut) {
                    showRequestsDropdown.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Text("Запросы")
                        .font(.headline)
                        .foregroundColor(.primary)

                    if viewModel.incomingRequests.count > 0 {
                        BadgeView(count: viewModel.incomingRequests.count)
                    }

                    Spacer()

                    Image(systemName: showRequestsDropdown ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: 240)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 6)
    }

    private var requestsDropdown: some View {
        VStack(spacing: 10) {
            if viewModel.isLoadingIncomingRequests {
                ProgressView()
                    .padding(.vertical, 18)
            } else if viewModel.incomingRequests.isEmpty {
                Text("Новых запросов нет")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 18)
            } else {
                ForEach(viewModel.incomingRequests) { request in
                    IncomingRequestRow(
                        request: request,
                        isProcessing: viewModel.pendingIncomingRequestIds.contains(request.id),
                        onAccept: {
                            viewModel.acceptIncomingRequest(request, currentUserId: authViewModel.currentUserId)
                        },
                        onReject: {
                            viewModel.rejectIncomingRequest(request)
                        }
                    )
                }
            }
        }
        .padding(12)
        .frame(maxWidth: 360)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 8)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingFriends && viewModel.friends.isEmpty {
            ProgressView()
        } else if viewModel.friends.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "person.2")
                    .font(.system(size: 42))
                    .foregroundColor(.secondary)
                Text("Список друзей пуст")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.friends) { friend in
                        UserRow(user: friend)
                    }
                }
                .padding()
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.top, 10)
        }
    }

    private var addFriendSheet: some View {
        NavigationView {
            VStack(spacing: 12) {
                searchField
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                if viewModel.isSearching {
                    ProgressView()
                        .padding(.top, 16)
                } else if searchText.trimmed.count >= 2 && viewModel.searchResults.isEmpty {
                    Text("Пользователи не найдены")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.searchResults) { user in
                                SearchUserRow(
                                    user: user,
                                    isSending: viewModel.pendingRequestUserIds.contains(user.id),
                                    isSent: viewModel.sentRequestUserIds.contains(user.id)
                                ) {
                                    viewModel.sendFriendRequest(to: user, currentUserId: authViewModel.currentUserId)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }

                Spacer(minLength: 0)
            }
            .navigationTitle("Добавить друга")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Готово") {
                        showAddFriend = false
                        searchText = ""
                        viewModel.clearSearch()
                    }
                }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Button {
                viewModel.toggleSearchMode(query: searchText, currentUserId: authViewModel.currentUserId)
            } label: {
                Text(viewModel.searchMode.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 34)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }

            TextField(viewModel.searchMode == .username ? "Введите имя" : "Введите @example", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onChange(of: searchText) { oldValue, newValue in
                    viewModel.searchUsers(query: newValue, currentUserId: authViewModel.currentUserId)
                }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}

private struct UserRow: View {
    let user: User

    var body: some View {
        HStack(spacing: 12) {
            Image("defaultAvatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 48, height: 48)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(displayShortId)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var displayShortId: String {
        guard let shortId = user.shortId?.trimmed, !shortId.isEmpty else {
            return "@unknown"
        }

        return shortId.hasPrefix("@") ? shortId : "@\(shortId)"
    }
}

private struct SearchUserRow: View {
    let user: User
    let isSending: Bool
    let isSent: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image("defaultAvatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 46, height: 46)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                Text(displayShortId)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onAdd) {
                Group {
                    if isSending {
                        ProgressView()
                    } else {
                        Image(systemName: isSent ? "checkmark" : "plus")
                            .font(.system(size: 17, weight: .bold))
                    }
                }
                .frame(width: 38, height: 38)
                .background(isSent ? Color.green.opacity(0.18) : Color.orange.opacity(0.18))
                .clipShape(Circle())
            }
            .disabled(isSending || isSent)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var displayShortId: String {
        guard let shortId = user.shortId?.trimmed, !shortId.isEmpty else {
            return "@unknown"
        }

        return shortId.hasPrefix("@") ? shortId : "@\(shortId)"
    }
}

private struct IncomingRequestRow: View {
    let request: FriendRequest
    let isProcessing: Bool
    let onAccept: () -> Void
    let onReject: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image("defaultAvatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 46, height: 46)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(request.sender.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(displayShortId)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onAccept) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.green)
                        .clipShape(Circle())
                }
                .disabled(isProcessing)

                Button(action: onReject) {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .disabled(isProcessing)
            }
            .opacity(isProcessing ? 0.45 : 1)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var displayShortId: String {
        guard let shortId = request.sender.shortId?.trimmed, !shortId.isEmpty else {
            return "@unknown"
        }

        return shortId.hasPrefix("@") ? shortId : "@\(shortId)"
    }
}

private struct BadgeView: View {
    let count: Int

    var body: some View {
        Text("\(min(count, 99))")
            .font(.caption2.weight(.bold))
            .foregroundColor(.white)
            .frame(minWidth: 18, minHeight: 18)
            .padding(.horizontal, count > 9 ? 4 : 0)
            .background(Color.red)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationView {
        FriendsPage()
            .environmentObject(AuthViewModel())
    }
}
