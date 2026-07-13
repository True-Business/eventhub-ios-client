//
//  EventRepository.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import Foundation

class EventRepository {
    private let eventApi: EventApi

    init(eventApi: EventApi = ApiProvider.shared.eventApi) {
        self.eventApi = eventApi
    }

    func fetchEvents(category: EventCategory = .all, completion: @escaping (Result<[Event], Error>) -> Void) {
        let filter = EventSearchFilterDto(
            city: nil,
            minPrice: nil,
            maxPrice: nil,
            startDateTime: nil,
            minDurationMinutes: nil,
            maxDurationMinutes: nil,
            organizerId: nil,
            isParticipant: nil,
            category: category == .all ? nil : category.rawValue,
            isOpen: nil
        )

        eventApi.searchEvents(filter: filter) { result in
            switch result {
            case .success(let dtos):
                completion(.success(dtos.map { $0.toDomainEvent() }))
            case .failure:
                self.eventApi.getEvents(category: category) { fallbackResult in
                    completion(fallbackResult.map { $0.map { $0.toDomainEvent() } }.mapError { $0 })
                }
            }
        }
    }

    func fetchEvent(eventId: UUID, completion: @escaping (Result<Event, Error>) -> Void) {
        eventApi.getEvent(id: eventId) { result in
            completion(result.map { $0.toDomainEvent() }.mapError { $0 })
        }
    }

    // Возвращает мок-мероприятие по id
    func fetchEventMock(eventId: String) -> Event? {
        mockEventList.first { $0.id.uuidString == eventId }
    }

    func searchEvents(query: String, completion: @escaping (Result<[Event], Error>) -> Void) {
        let query = query.trimmed

        fetchEvents { result in
            completion(result.map { events in
                events.filter { event in
                    event.title.localizedCaseInsensitiveContains(query)
                        || event.content.localizedCaseInsensitiveContains(query)
                        || event.location.localizedCaseInsensitiveContains(query)
                }
            })
        }
    }

    func createEvent(_ event: Event, completion: @escaping (Result<Event, Error>) -> Void) {
        eventApi.createEvent(dto: event.toCreateUpdateDto()) { result in
            completion(result.map { $0.toDomainEvent() }.mapError { $0 })
        }
    }

    func deleteEvent(eventId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        eventApi.deleteEvent(eventId: eventId) { result in
            completion(result.mapError { $0 })
        }
    }

    func registerToEvent(eventId: UUID, userId: UUID, completion: @escaping (Result<Event, Error>) -> Void) {
        eventApi.registerToEvent(eventId: eventId, userId: userId) { result in
            switch result {
            case .success:
                self.fetchEvent(eventId: eventId, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func unregisterFromEvent(eventId: UUID, completion: @escaping (Result<Event, Error>) -> Void) {
        eventApi.unregisterFromEvent(eventId: eventId) { result in
            switch result {
            case .success:
                self.fetchEvent(eventId: eventId, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchParticipants(eventId: UUID, completion: @escaping (Result<[User], Error>) -> Void) {
        eventApi.getParticipants(eventId: eventId) { result in
            completion(result.map { $0.map { $0.toDomainUser() } }.mapError { $0 })
        }
    }
}
