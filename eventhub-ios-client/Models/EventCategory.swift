//
//  EventCategory.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//

enum EventCategory: String, Codable, CaseIterable, Identifiable {
    case all = "ALL"
    case festivals = "FESTIVALS"
    case meetings = "MEETINGS"
    case shows = "SHOWS"
    case music = "MUSIC"
    case films = "FILMS"
    case restaurants = "RESTAURANTS"
    case placeholder = "PLACEHOLDER"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all:
            return "Все"
        case .festivals:
            return "Фестивали"
        case .meetings:
            return "Встречи"
        case .shows:
            return "Шоу"
        case .music:
            return "Музыка"
        case .films:
            return "Фильмы"
        case .restaurants:
            return "Рестораны"
        case .placeholder:
            return "Другое"
        }
    }
}
