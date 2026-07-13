//
//  Event.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import Foundation

struct Event: Identifiable {
    let id: UUID
    let category: [EventCategory]
    let title: String
    let content: String
    let startDate: String
    let endDate: String
    let location: String
    let posterUrl: String
    let imageUrls: [String]
    let organizerId: UUID?
    let organizationId: UUID?
    let updatedAt: String?
    let address: String
    let route: String
    let city: String
    let peopleLimit: Int
    let registerEndDateTime: String?
    let withRegister: Bool
    let open: Bool
    let price: Double?
    let eventStatus: EventStatus
    let isUserParticipating: Bool
    let isOwner: Bool
    let participantsCount: Int
    let isFinished: Bool

    init(
        id: UUID,
        category: [EventCategory],
        title: String,
        content: String,
        startDate: String,
        endDate: String,
        location: String,
        posterUrl: String,
        imageUrls: [String] = [],
        organizerId: UUID? = nil,
        organizationId: UUID? = nil,
        updatedAt: String? = nil,
        address: String = "",
        route: String = "",
        city: String = "",
        peopleLimit: Int = Int.max,
        registerEndDateTime: String? = nil,
        withRegister: Bool = false,
        open: Bool = true,
        price: Double? = nil,
        eventStatus: EventStatus = .planned,
        isUserParticipating: Bool = false,
        isOwner: Bool = false,
        participantsCount: Int = 0,
        isFinished: Bool = false
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.content = content
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.posterUrl = posterUrl
        self.imageUrls = imageUrls
        self.organizerId = organizerId
        self.organizationId = organizationId
        self.updatedAt = updatedAt
        self.address = address
        self.route = route
        self.city = city
        self.peopleLimit = peopleLimit
        self.registerEndDateTime = registerEndDateTime
        self.withRegister = withRegister
        self.open = open
        self.price = price
        self.eventStatus = eventStatus
        self.isUserParticipating = isUserParticipating
        self.isOwner = isOwner
        self.participantsCount = participantsCount
        self.isFinished = isFinished
    }
}

enum EventStatus: String, Codable, CaseIterable, Identifiable {
    case draft = "DRAFT"
    case published = "PUBLISHED"
    case planned = "PLANNED"
    case cancelled = "CANCELLED"
    case completed = "COMPLETED"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .draft:
            return "Черновик"
        case .published:
            return "Опубликовано"
        case .planned:
            return "Запланировано"
        case .cancelled:
            return "Отменено"
        case .completed:
            return "Завершено"
        }
    }
}

enum EventsMainTab: String, CaseIterable, Identifiable {
    case visits
    case events

    var id: String { rawValue }

    var title: String {
        switch self {
        case .visits:
            return "Посещения"
        case .events:
            return "Мероприятия"
        }
    }
}

enum EventsListCategory: String, CaseIterable, Identifiable {
    case drafts
    case planned
    case completed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .drafts:
            return "Черновики"
        case .planned:
            return "Запланированные"
        case .completed:
            return "Проведенные"
        }
    }

    var statuses: Set<EventStatus> {
        switch self {
        case .drafts:
            return [.draft]
        case .planned:
            return [.planned, .published]
        case .completed:
            return [.completed]
        }
    }
}
