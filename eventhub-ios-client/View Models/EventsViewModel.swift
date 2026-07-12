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
    @Published var selectedCategory: EventCategory = .all
        
    init(repository: EventRepository = EventRepository()) {
        self.repository = repository
    }
    
    func loadEvents() {
        if isLoading { return }
            
        isLoading = true
        print("Загрузка новых мероприятий категории \(selectedCategory)...")
            
        repository.fetchEventsMock(category: selectedCategory) { [weak self] newEvents in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let newEvents = newEvents {
                    self?.events += newEvents
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
        print("Поиск мероприятий по запросу: \(query)")
        
        repository.searchMockEvents(query: query) { [weak self] newEvents in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.searchResults = newEvents ?? []
            }
        }
    }

    func clearSearch() {
        searchResults = []
    }
}
