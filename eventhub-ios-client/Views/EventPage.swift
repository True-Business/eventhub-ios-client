//
//  EventPage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import SwiftUI

struct EventPage: View {
    @ObservedObject var eventsViewModel: EventsViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var event: Event
    @State private var isUpdatingParticipation = false
    @State private var isDeletingEvent = false
    @State private var showDeleteConfirmation = false
    @State private var participationError: String?
    @State private var participants: [User] = []
    @State private var participantsError: String?
    @State private var isLoadingParticipants = false
    @State private var showParticipants = false
    @State private var isLoadingEventDetails = false
    @State private var eventDetailsError: String?

    init(event: Event, eventsViewModel: EventsViewModel) {
        self.eventsViewModel = eventsViewModel
        _event = State(initialValue: event)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                EventImagesSection(imageUrls: event.detailImageUrls)
                EventMainInfoSection(event: event) {
                    openParticipants()
                }
                EventAdditionalInfoSection(event: event)
                EventActionsSection(
                    event: event,
                    isUpdatingParticipation: isUpdatingParticipation,
                    participationError: participationError
                ) { shouldParticipate in
                    setParticipation(shouldParticipate)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.38, blue: 0.0).opacity(0.18),
                    Color(red: 1.0, green: 0.65, blue: 0.0).opacity(0.10),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                    } label: {
                        Label("Поделиться", systemImage: "square.and.arrow.up")
                    }

                    if event.isOwner {
                        Button {
                        } label: {
                            Label("Редактировать", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                        .disabled(isDeletingEvent)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 32, height: 32)
                }
            }
        }
        .sheet(isPresented: $showParticipants) {
            NavigationView {
                ParticipantsSheet(
                    participants: participants,
                    isLoading: isLoadingParticipants,
                    errorMessage: participantsError
                )
                .navigationTitle("Участники")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .alert("Удалить мероприятие?", isPresented: $showDeleteConfirmation) {
            Button("Удалить", role: .destructive) {
                deleteEvent()
            }

            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Мероприятие будет удалено для всех пользователей.")
        }
        .task {
            loadEventDetails()
        }
    }

    private func loadEventDetails() {
        guard !isLoadingEventDetails else { return }

        isLoadingEventDetails = true
        eventDetailsError = nil

        eventsViewModel.loadEvent(eventId: event.id, replaceInLists: false) { result in
            isLoadingEventDetails = false

            switch result {
            case .success(let loadedEvent):
                event = loadedEvent
            case .failure(let error):
                eventDetailsError = error.localizedDescription
            }
        }
    }

    private func setParticipation(_ shouldParticipate: Bool) {
        guard !isUpdatingParticipation else { return }

        isUpdatingParticipation = true
        participationError = nil

        eventsViewModel.setParticipation(
            for: event,
            userId: authViewModel.currentUserId,
            isParticipating: shouldParticipate
        ) { result in
            isUpdatingParticipation = false

            switch result {
            case .success(let updatedEvent):
                event = updatedEvent
            case .failure(let error):
                participationError = error.localizedDescription
            }
        }
    }

    private func deleteEvent() {
        guard !isDeletingEvent else { return }

        isDeletingEvent = true
        participationError = nil

        eventsViewModel.deleteEvent(event) { result in
            isDeletingEvent = false

            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                participationError = error.localizedDescription
            }
        }
    }

    private func openParticipants() {
        showParticipants = true

        guard !isLoadingParticipants else { return }
        isLoadingParticipants = true
        participantsError = nil

        eventsViewModel.loadParticipants(for: event) { result in
            isLoadingParticipants = false

            switch result {
            case .success(let users):
                participants = users
            case .failure(let error):
                participants = []
                participantsError = error.localizedDescription
            }
        }
    }
}

private struct EventImagesSection: View {
    let imageUrls: [String]
    @State private var selectedImageIndex = 0
    @State private var showFullScreenImage = false

    var body: some View {
        if !imageUrls.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                TabView(selection: $selectedImageIndex) {
                    ForEach(Array(imageUrls.enumerated()), id: \.offset) { index, url in
                        Button {
                            selectedImageIndex = index
                            showFullScreenImage = true
                        } label: {
                            EventPosterImage(urlString: url, height: 240)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        .tag(index)
                    }
                }
                .frame(height: 240)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: imageUrls.count > 1 ? .automatic : .never))

                if imageUrls.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(imageUrls.enumerated()), id: \.offset) { index, url in
                                Button {
                                    selectedImageIndex = index
                                } label: {
                                    EventPosterImage(urlString: url, height: 64)
                                        .frame(width: 64, height: 64)
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .stroke(index == selectedImageIndex ? Color.accentColor : Color.clear, lineWidth: 2)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .fullScreenCover(isPresented: $showFullScreenImage) {
                FullScreenImageViewer(
                    imageUrls: imageUrls,
                    initialIndex: selectedImageIndex,
                    onDismiss: { showFullScreenImage = false }
                )
            }
        }
    }
}

private struct EventMainInfoSection: View {
    let event: Event
    let onParticipantsTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(event.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .fixedSize(horizontal: false, vertical: true)

                InfoRow(icon: "calendar", text: event.scheduleText)

                if !event.city.isBlank {
                    InfoRow(icon: "mappin.and.ellipse", text: event.city)
                    if !event.address.isBlank {
                        Text(event.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 32)
                    }
                } else if !event.location.isBlank {
                    InfoRow(icon: "mappin.and.ellipse", text: event.location)
                }
            }

            Divider()

            HStack(alignment: .center) {
                StatusChip(isOpen: event.open)

                Spacer()

                Button(action: onParticipantsTap) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text(event.participantsText)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.accentColor.opacity(0.10))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)
    }
}

private struct EventAdditionalInfoSection: View {
    let event: Event

    var body: some View {
        if hasContent {
            VStack(alignment: .leading, spacing: 20) {
                if !event.content.isBlank {
                    InfoBlock(title: "Описание", text: event.content)
                }

                if !event.route.isBlank {
                    InfoBlock(title: "Как добраться", text: event.route)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)
        }
    }

    private var hasContent: Bool {
        !event.content.isBlank || !event.route.isBlank
    }
}

private struct EventActionsSection: View {
    let event: Event
    let isUpdatingParticipation: Bool
    let participationError: String?
    let onParticipationChange: (Bool) -> Void

    var body: some View {
        VStack(spacing: 12) {
            if let primaryButton = primaryButton {
                Button {
                    guard primaryButton.enabled else { return }
                    onParticipationChange(!event.isUserParticipating)
                } label: {
                    HStack(spacing: 8) {
                        if isUpdatingParticipation {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(primaryButton.text)
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: primaryButton.colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .opacity(primaryButton.enabled ? 1 : 0.45)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .disabled(!primaryButton.enabled || isUpdatingParticipation)
            }

            if let participationError {
                Text(participationError)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)
    }

    private var primaryButton: (text: String, enabled: Bool, colors: [Color])? {
        let limitReached = event.peopleLimit != Int.max && event.participantsCount >= event.peopleLimit
        let activeColors = [
            Color(red: 1.0, green: 0.38, blue: 0.0),
            Color(red: 1.0, green: 0.65, blue: 0.0)
        ]
        let participatingColors = [
            Color(red: 0.18, green: 0.62, blue: 0.33),
            Color(red: 0.32, green: 0.74, blue: 0.39)
        ]

        if !event.withRegister {
            return nil
        }

        if event.isFinished && event.isUserParticipating {
            return ("Вы участвовали", false, participatingColors)
        }

        if event.isFinished && !event.isUserParticipating {
            return nil
        }

        if event.isUserParticipating {
            return ("Вы записаны", true, participatingColors)
        }

        if limitReached {
            return ("Лимит участников достигнут", false, activeColors)
        }

        return ("Хочу пойти", true, activeColors)
    }
}

private struct ParticipantsSheet: View {
    let participants: [User]
    let isLoading: Bool
    let errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if participants.isEmpty {
                Text("Пока нет участников")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(participants) { user in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.headline)

                        if let shortId = user.shortId, !shortId.isBlank {
                            Text(shortId.hasPrefix("@") ? shortId : "@\(shortId)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

private struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 22)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct InfoBlock: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)

            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct StatusChip: View {
    let isOpen: Bool

    var body: some View {
        Text(isOpen ? "Открытое мероприятие" : "Закрытое мероприятие")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(isOpen ? Color(red: 0.18, green: 0.49, blue: 0.20) : Color(red: 0.83, green: 0.18, blue: 0.18))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isOpen ? Color(red: 0.90, green: 0.96, blue: 0.92) : Color(red: 1.0, green: 0.90, blue: 0.90))
            .clipShape(Capsule())
    }
}

private struct ActionButton: View {
    let icon: String
    let title: String
    var roleColor: Color = .accentColor
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundColor(roleColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(roleColor.opacity(0.35), lineWidth: 1)
            )
        }
    }
}

private extension Event {
    var detailImageUrls: [String] {
        var urls = imageUrls
        let poster = posterUrl.trimmingCharacters(in: .whitespacesAndNewlines)

        if !poster.isEmpty && !urls.contains(poster) {
            urls.insert(poster, at: 0)
        }

        return urls
    }

    var scheduleText: String {
        let start = formattedEventDate(startDate)
        let end = formattedEventDate(endDate)

        if start == end {
            return start
        }

        return "\(start) - \(end)"
    }

    var participantsText: String {
        if peopleLimit == Int.max {
            return "\(participantsCount)"
        }

        return "\(participantsCount)/\(peopleLimit)"
    }

    private func formattedEventDate(_ value: String) -> String {
        guard let date = Date.parseEventHubIsoString(value) else {
            return value
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter.string(from: date)
    }
}
