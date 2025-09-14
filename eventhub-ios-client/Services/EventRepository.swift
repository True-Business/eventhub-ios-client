//
//  EventRepository.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import Foundation

class EventRepository {
    
    
    // Возвращает заготовленные данные для тестирования с фильтром по категории
    func fetchEventsMock(category: EventCategory = .all, completion: @escaping ([Event]?) -> Void) {
        let filtered = mockEventList.filter { $0.category.contains(category) }
        completion(filtered)
    }
    
    // Возвращает мок-мероприятие по id
    func fetchEventMock(eventId: String) -> Event? {
        return mockEventList.first { $0.id.uuidString == eventId }
    }
    
    // Поиск мероприятий по query (мок)
    func searchMockEvents(query: String, completion: @escaping ([Event]?) -> Void) {
        let filtered = mockEventList.filter { $0.title.localizedCaseInsensitiveContains(query) }
        completion(filtered)
    }
}
