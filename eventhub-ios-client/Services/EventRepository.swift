//
//  EventRepository.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import Foundation

class EventRepository {
    private let eventApi: EventApi
    private let storageApi: StorageApi

    init(
        eventApi: EventApi = ApiProvider.shared.eventApi,
        storageApi: StorageApi = ApiProvider.shared.storageApi
    ) {
        self.eventApi = eventApi
        self.storageApi = storageApi
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

    func createEvent(
        _ event: Event,
        images: [EventImageUpload],
        completion: @escaping (Result<Event, Error>) -> Void
    ) {
        createEvent(event) { result in
            switch result {
            case .success(let createdEvent):
                guard !images.isEmpty else {
                    completion(.success(createdEvent))
                    return
                }

                self.uploadImages(images, eventId: createdEvent.id) { uploadResult in
                    switch uploadResult {
                    case .success:
                        self.fetchEvent(eventId: createdEvent.id, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
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

    private func uploadImages(
        _ images: [EventImageUpload],
        eventId: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let request = ObjectUploadRequestDto(
            ownerId: eventId.uuidString,
            ownerType: "EVENT",
            originNames: images.map(\.originName)
        )

        storageApi.genUploadUrls(request: request) { result in
            switch result {
            case .success(let response):
                self.uploadImageData(images, urlInfos: response.urls, eventId: eventId, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func uploadImageData(
        _ images: [EventImageUpload],
        urlInfos: [ObjectUploadUrlInfoDto],
        eventId: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let imagesByOrigin = Dictionary(uniqueKeysWithValues: images.map { ($0.originName, $0) })
        let uploadTargets = urlInfos.compactMap { urlInfo -> (ObjectUploadUrlInfoDto, EventImageUpload)? in
            guard let image = imagesByOrigin[urlInfo.origin], urlInfo.url != nil else {
                return nil
            }

            return (urlInfo, image)
        }

        guard !uploadTargets.isEmpty else {
            confirmUpload(urlInfos: urlInfos, eventId: eventId, completion: completion)
            return
        }

        let group = DispatchGroup()
        var firstError: Error?
        let errorLock = NSLock()

        for (urlInfo, image) in uploadTargets {
            guard let url = urlInfo.url else { continue }

            group.enter()
            storageApi.upload(data: image.data, to: url) { result in
                if case .failure(let error) = result {
                    errorLock.lock()
                    if firstError == nil {
                        firstError = error
                    }
                    errorLock.unlock()
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let firstError {
                completion(.failure(firstError))
            } else {
                self.confirmUpload(urlInfos: urlInfos, eventId: eventId, completion: completion)
            }
        }
    }

    private func confirmUpload(
        urlInfos: [ObjectUploadUrlInfoDto],
        eventId: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let request = ObjectConfirmRequestDto(
            ownerId: eventId.uuidString,
            ownerType: "EVENT",
            ids: urlInfos.map(\.id)
        )

        storageApi.confirmUpload(request: request) { result in
            completion(result.map { _ in () }.mapError { $0 })
        }
    }
}
