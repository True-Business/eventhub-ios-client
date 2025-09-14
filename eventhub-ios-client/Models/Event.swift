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
    let posterUrl: Int
}
