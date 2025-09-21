//
//  EventViewModel.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import Foundation
import Combine

class EventsViewModel: ObservableObject {
    
    private let repository = EventRepository()
        
    @Published var events: [Event] = []
    @Published var searchResults: [Event] = []
    @Published var isLoading: Bool = false
    @Published var selectedCategory: EventCategory = .all
        
    private var cancellables = Set<AnyCancellable>()
    
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
        if isLoading { return }
        
        isLoading = true
        print("Поиск мероприятий по запросу: \(query)")
        
        repository.searchMockEvents(query: query) { [weak self] newEvents in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let newEvents = newEvents {
                    self?.searchResults = newEvents
                }
            }
        }
    }
}
