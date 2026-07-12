//
//  EventPage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import SwiftUI

struct EventPage: View {
    let event: Event

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                EventMainInfoSection(event: event)
                EventAdditionalInfoSection(event: event)
                EventActionsSection(event: event)
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
    }
}

private struct EventMainInfoSection: View {
    let event: Event

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

                Text("Участники: \(event.participantsText)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
    @State private var isParticipating: Bool

    init(event: Event) {
        self.event = event
        _isParticipating = State(initialValue: event.isUserParticipating)
    }

    var body: some View {
        VStack(spacing: 12) {
            if let primaryButton = primaryButton {
                Button {
                    guard primaryButton.enabled else { return }
                    isParticipating.toggle()
                } label: {
                    Text(primaryButton.text)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.38, blue: 0.0),
                                    Color(red: 1.0, green: 0.65, blue: 0.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .opacity(primaryButton.enabled ? 1 : 0.45)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .disabled(!primaryButton.enabled)
            }

            HStack(spacing: 12) {
                ActionButton(icon: "square.and.arrow.up", title: "Поделиться") {}
                ActionButton(icon: "person.fill", title: "Участники") {}
            }

            ActionButton(icon: "pencil", title: "Редактировать") {}
            ActionButton(icon: "trash", title: "Отменить", roleColor: .red) {}
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)
    }

    private var primaryButton: (text: String, enabled: Bool)? {
        let limitReached = event.peopleLimit != Int.max && event.participantsCount >= event.peopleLimit

        if event.isFinished && isParticipating {
            return ("Вы участвовали", false)
        }

        if event.isFinished && !isParticipating {
            return nil
        }

        if isParticipating {
            return ("Не смогу пойти", true)
        }

        if limitReached {
            return ("Лимит участников достигнут", false)
        }

        return ("Хочу пойти", true)
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
