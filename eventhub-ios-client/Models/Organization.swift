//
//  Organization.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 17.10.2025.
//
import Foundation

struct Organization: Identifiable {
    let id: UUID
    var name: String
    let coverUrl: String
    var description: String
    var address: String
    var admins: [User]
    var images: [String]
    var events: [Event]
}
