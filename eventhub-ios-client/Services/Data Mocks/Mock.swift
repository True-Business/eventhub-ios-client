//
//  Mock.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import Foundation

let mockEventList: [Event] = [
    Event(
        id: UUID(),
        category: [.all, .festivals],
        title: "Smart Picnic",
        content: "Ежегодное мероприятие с множеством развлечений, концертом и т.п.",
        startDate: "2024-12-01",
        endDate: "2024-12-02",
        location: "Академгородок, ул. Николаева, 11",
        posterUrl: 1
    ),
    Event(
        id: UUID(),
        category: [.all, .festivals],
        title: "OpenSpacePicnic",
        content: "Пикник в дворике нового корпуса НГУ посвящённый дню знаний.",
        startDate: "2024-12-01",
        endDate: "2024-12-02",
        location: "Академгородок, ул. Пирогова, 1",
        posterUrl: 2
    ),
    Event(
        id: UUID(),
        category: [.all, .meetings],
        title: "День открытых дверей в НГУ",
        content: "Выставка факультетов, общение со студентами и многое другое.",
        startDate: "2024-12-01",
        endDate: "2024-12-02",
        location: "Академгородок, ул. Пирогова, 1",
        posterUrl: 3
    ),
    Event(
        id: UUID(),
        category: [.all, .shows],
        title: "ХАХА BATTLE НГУ",
        content: "Самое смешное юмористическое соревнование в Академгородке.",
        startDate: "2024-11-15",
        endDate: "2024-11-15",
        location: "Академгородок, Проспект Строителей, 21",
        posterUrl: 4
    ),
    Event(
        id: UUID(),
        category: [.all, .music],
        title: "3 дня дождя",
        content: "Концерт группы 3 дня дождя",
        startDate: "2024-11-13",
        endDate: "2024-11-13",
        location: "Новосибирск, Локомотив-Арена",
        posterUrl: 5
    ),
    Event(
        id: UUID(),
        category: [.all, .shows],
        title: "Андрей Бебуришвили",
        content: "Стендап 18+",
        startDate: "2025-02-15",
        endDate: "2025-02-15",
        location: "Новосибирск, ККК им.Маяковского",
        posterUrl: 6
    ),
    Event(
        id: UUID(),
        category: [.all, .films],
        title: "Веном: Последний танец",
        content: """
        Приспособившись к совместному существованию, Эдди и Веном стали друзьями и вместе сражаются со злодеями. Но теперь за Эдди охотятся военные, а за Веномом — его инопланетные сородичи, угрожающие всему живому.
        """,
        startDate: "2024-10-24",
        endDate: "2024-11-30",
        location: "Академгородок, ул. Кутателадзе, 4/4",
        posterUrl: 7
    )
]
