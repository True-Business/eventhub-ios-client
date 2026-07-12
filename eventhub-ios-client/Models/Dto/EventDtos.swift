//
//  EventDtos.swift
//  eventhub-ios-client
//

import Foundation

struct EventDto: Decodable {
    let id: String
    let name: String
    let startDateTime: String
    let endDateTime: String
    let updatedAt: String?
    let organizerId: String?
    let organizationId: String?
    let category: String?
    let address: String?
    let route: String?
    let description: String?
    let price: Double?
    let status: String?
    let city: String?
    let peopleLimit: Int?
    let registerEndDateTime: String?
    let withRegister: Bool?
    let open: Bool?
    let participantsCount: Int?
    let userParticipant: Bool?
}

struct EventCreateUpdateDto: Encodable {
    let name: String?
    let startDateTime: String?
    let endDateTime: String?
    let organizerId: String?
    let organizationId: String?
    let category: String?
    let address: String?
    let route: String?
    let description: String?
    let price: Double?
    let status: String?
    let city: String?
    let peopleLimit: Int?
    let registerEndDateTime: String?
    let isWithRegister: Bool?
    let isOpen: Bool?
}

struct EventSearchFilterDto: Encodable {
    let city: String?
    let minPrice: Double?
    let maxPrice: Double?
    let startDateTime: String?
    let minDurationMinutes: Int?
    let maxDurationMinutes: Int?
    let organizerId: String?
    let isParticipant: Bool?
    let category: String?
    let isOpen: Bool?
}

extension EventDto {
    func toDomainEvent() -> Event {
        let category = EventCategory(rawValue: category?.uppercased() ?? "") ?? .placeholder
        let address = address ?? ""
        let route = route ?? ""
        let city = city ?? ""
        let location = [address, route, city]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: ", ")

        return Event(
            id: UUID(uuidString: id) ?? UUID(),
            category: [category],
            title: name,
            content: description ?? "",
            startDate: startDateTime,
            endDate: endDateTime,
            location: location.isEmpty ? city : location,
            posterUrl: "",
            organizerId: organizerId.flatMap(UUID.init(uuidString:)),
            organizationId: organizationId.flatMap(UUID.init(uuidString:)),
            updatedAt: updatedAt,
            address: address,
            route: route,
            city: city,
            peopleLimit: peopleLimit ?? Int.max,
            registerEndDateTime: registerEndDateTime,
            withRegister: withRegister ?? false,
            open: open ?? true,
            price: price == 0 ? nil : price,
            eventStatus: EventStatus(rawValue: status?.uppercased() ?? "") ?? .draft,
            isUserParticipating: userParticipant ?? false,
            participantsCount: participantsCount ?? 0,
            isFinished: Date.parseEventHubIsoString(endDateTime).map { $0 < Date() } ?? false
        )
    }
}

extension Event {
    func toCreateUpdateDto() -> EventCreateUpdateDto {
        EventCreateUpdateDto(
            name: title,
            startDateTime: startDate,
            endDateTime: endDate,
            organizerId: organizerId?.uuidString,
            organizationId: organizationId?.uuidString,
            category: category.first?.rawValue ?? EventCategory.placeholder.rawValue,
            address: address.isEmpty ? location : address,
            route: route,
            description: content,
            price: price ?? 0,
            status: eventStatus.rawValue,
            city: city,
            peopleLimit: peopleLimit == Int.max ? nil : peopleLimit,
            registerEndDateTime: registerEndDateTime ?? startDate,
            isWithRegister: withRegister,
            isOpen: open
        )
    }
}

extension Date {
    static let eventHubIsoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let eventHubIsoFormatterNoFractions: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    func toEventHubIsoString() -> String {
        Date.eventHubIsoFormatterNoFractions.string(from: self)
    }

    static func parseEventHubIsoString(_ string: String) -> Date? {
        eventHubIsoFormatter.date(from: string) ?? eventHubIsoFormatterNoFractions.date(from: string)
    }
}
