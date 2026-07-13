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
    let owner: Bool?
    let posterUrl: String?
    let imageUrls: [String]?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case startDateTime
        case endDateTime
        case updatedAt
        case organizerId
        case organizationId
        case category
        case address
        case route
        case description
        case price
        case status
        case city
        case peopleLimit
        case registerEndDateTime
        case withRegister
        case isWithRegister
        case open
        case isOpen
        case participantsCount
        case userParticipant
        case isUserParticipant
        case owner
        case isOwner
        case posterUrl
        case posterURL
        case imageUrls
        case imageURLs
        case images
        case pictures
        case presignedUrls
        case presignedURLs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startDateTime = try container.decode(String.self, forKey: .startDateTime)
        endDateTime = try container.decode(String.self, forKey: .endDateTime)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        organizerId = try container.decodeIfPresent(String.self, forKey: .organizerId)
        organizationId = try container.decodeIfPresent(String.self, forKey: .organizationId)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        route = try container.decodeIfPresent(String.self, forKey: .route)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        price = try container.decodeIfPresent(Double.self, forKey: .price)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        peopleLimit = try container.decodeIfPresent(Int.self, forKey: .peopleLimit)
        registerEndDateTime = try container.decodeIfPresent(String.self, forKey: .registerEndDateTime)
        withRegister = try container.decodeIfPresent(Bool.self, forKey: .withRegister)
            ?? container.decodeIfPresent(Bool.self, forKey: .isWithRegister)
        open = try container.decodeIfPresent(Bool.self, forKey: .open)
            ?? container.decodeIfPresent(Bool.self, forKey: .isOpen)
        participantsCount = try container.decodeIfPresent(Int.self, forKey: .participantsCount)
        userParticipant = try container.decodeIfPresent(Bool.self, forKey: .userParticipant)
            ?? container.decodeIfPresent(Bool.self, forKey: .isUserParticipant)
        owner = try container.decodeIfPresent(Bool.self, forKey: .owner)
            ?? container.decodeIfPresent(Bool.self, forKey: .isOwner)
        posterUrl = try container.decodeIfPresent(String.self, forKey: .posterUrl)
            ?? container.decodeIfPresent(String.self, forKey: .posterURL)
        imageUrls = try Self.decodeFirstStringArray(
            from: container,
            keys: [.imageUrls, .imageURLs, .images, .pictures, .presignedUrls, .presignedURLs]
        )
    }

    private static func decodeFirstStringArray(
        from container: KeyedDecodingContainer<CodingKeys>,
        keys: [CodingKeys]
    ) throws -> [String]? {
        for key in keys {
            if let values = try container.decodeIfPresent([String].self, forKey: key) {
                return values
            }
        }

        return nil
    }
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

struct EventParticipantUserDto: Decodable {
    let id: String
    let username: String
    let shortId: String?
}

extension EventParticipantUserDto {
    func toDomainUser() -> User {
        User(
            id: UUID(uuidString: id) ?? UUID(),
            name: username,
            shortId: shortId
        )
    }
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
        let cleanImageUrls = (imageUrls ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let cleanPosterUrl = posterUrl?.trimmingCharacters(in: .whitespacesAndNewlines) ?? cleanImageUrls.first ?? ""

        return Event(
            id: UUID(uuidString: id) ?? UUID(),
            category: [category],
            title: name,
            content: description ?? "",
            startDate: startDateTime,
            endDate: endDateTime,
            location: location.isEmpty ? city : location,
            posterUrl: cleanPosterUrl,
            imageUrls: cleanImageUrls,
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
            isOwner: owner ?? false,
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
