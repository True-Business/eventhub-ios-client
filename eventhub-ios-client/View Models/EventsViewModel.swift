//
//  EventViewModel.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import Foundation

class EventsViewModel: ObservableObject {
    
    private let repository: EventRepository
        
    @Published var events: [Event] = []
    @Published var searchResults: [Event] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedCategory: EventCategory = .all
    @Published var eventsMainTab: EventsMainTab = .visits
    @Published var eventsListCategory: EventsListCategory = .drafts
        
    init(repository: EventRepository = EventRepository()) {
        self.repository = repository
    }
    
    func loadEvents() {
        if isLoading { return }
            
        isLoading = true
        errorMessage = nil
        print("Загрузка новых мероприятий категории \(selectedCategory)...")
            
        repository.fetchEvents(category: selectedCategory) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let newEvents):
                    self?.events = newEvents
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
                print("Новые мероприятия загружены!")
            }
        }
    }
    
    func searchEvents(query: String) {
        let query = query.trimmed
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        if isLoading { return }
        
        isLoading = true
        errorMessage = nil
        print("Поиск мероприятий по запросу: \(query)")
        
        repository.searchEvents(query: query) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let newEvents):
                    self?.searchResults = newEvents
                case .failure(let error):
                    self?.searchResults = []
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func clearSearch() {
        searchResults = []
    }

    func replaceEvent(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }

        if let index = searchResults.firstIndex(where: { $0.id == event.id }) {
            searchResults[index] = event
        }
    }

    func removeEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
        searchResults.removeAll { $0.id == event.id }
    }

    func loadEvent(
        eventId: UUID,
        replaceInLists: Bool = true,
        completion: @escaping (Result<Event, Error>) -> Void
    ) {
        repository.fetchEvent(eventId: eventId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let event):
                    if replaceInLists {
                        self?.replaceEvent(event)
                    }
                    completion(.success(event))
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }

    func deleteEvent(_ event: Event, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.deleteEvent(eventId: event.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.removeEvent(event)
                    completion(.success(()))
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }

    func setParticipation(
        for event: Event,
        userId: String?,
        isParticipating: Bool,
        completion: @escaping (Result<Event, Error>) -> Void
    ) {
        guard let userId = userId.flatMap(UUID.init(uuidString:)) else {
            errorMessage = "Не удалось определить пользователя"
            completion(.failure(ParticipationError.missingUserId))
            return
        }

        let handler: (Result<Event, Error>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedEvent):
                    self?.replaceEvent(updatedEvent)
                    completion(.success(updatedEvent))
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }

        if isParticipating {
            repository.registerToEvent(eventId: event.id, userId: userId, completion: handler)
        } else {
            repository.unregisterFromEvent(eventId: event.id, completion: handler)
        }
    }

    func loadParticipants(
        for event: Event,
        completion: @escaping (Result<[User], Error>) -> Void
    ) {
        repository.fetchParticipants(eventId: event.id) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func eventsForCurrentEventsScreen(currentUserId: String?) -> [Event] {
        events.filter { event in
            switch eventsMainTab {
            case .visits:
                return event.isUserParticipating
            case .events:
                let belongsToCurrentUser = currentUserId.flatMap(UUID.init(uuidString:)) == event.organizerId
                return eventsListCategory.statuses.contains(event.eventStatus) && (currentUserId == nil || belongsToCurrentUser)
            }
        }
        .sorted { $0.startDate < $1.startDate }
    }

    func createEvent(
        title: String,
        description: String,
        city: String,
        address: String,
        route: String,
        startDate: Date,
        endDate: Date,
        price: Double?,
        peopleLimit: Int?,
        withRegister: Bool,
        isOpen: Bool,
        category: EventCategory,
        status: EventStatus,
        organizerId: String?,
        imageUploads: [EventImageUpload] = [],
        completion: @escaping (Bool) -> Void
    ) {
        guard !isLoading else {
            completion(false)
            return
        }

        let trimmedTitle = title.trimmed
        let trimmedDescription = description.trimmed
        let trimmedCity = city.trimmed
        let trimmedAddress = address.trimmed
        let trimmedRoute = route.trimmed

        guard
            trimmedTitle.count >= 3,
            trimmedDescription.count >= 3,
            !trimmedCity.isEmpty,
            !trimmedAddress.isEmpty,
            endDate > startDate
        else {
            errorMessage = "Заполните обязательные поля и проверьте даты"
            completion(false)
            return
        }

        let event = Event(
            id: UUID(),
            category: [category],
            title: trimmedTitle,
            content: trimmedDescription,
            startDate: startDate.toEventHubIsoString(),
            endDate: endDate.toEventHubIsoString(),
            location: [trimmedAddress, trimmedRoute, trimmedCity].filter { !$0.isEmpty }.joined(separator: ", "),
            posterUrl: "",
            organizerId: organizerId.flatMap(UUID.init(uuidString:)),
            organizationId: nil,
            updatedAt: nil,
            address: trimmedAddress,
            route: trimmedRoute,
            city: trimmedCity,
            peopleLimit: peopleLimit ?? Int.max,
            registerEndDateTime: startDate.toEventHubIsoString(),
            withRegister: withRegister,
            open: isOpen,
            price: price,
            eventStatus: status,
            isUserParticipating: false,
            isOwner: true,
            participantsCount: 0,
            isFinished: false
        )

        isLoading = true
        errorMessage = nil

        repository.createEvent(event, images: imageUploads) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let createdEvent):
                    self?.events.removeAll { $0.id == createdEvent.id }
                    self?.events.insert(createdEvent, at: 0)
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}

private enum ParticipationError: LocalizedError {
    case missingUserId

    var errorDescription: String? {
        switch self {
        case .missingUserId:
            return "Не удалось определить пользователя"
        }
    }
}
