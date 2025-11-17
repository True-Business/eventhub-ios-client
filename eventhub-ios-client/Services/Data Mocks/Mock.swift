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
        posterUrl: "https://nadvizh.ru/media/events_img/67/smart-piknik_logo.jpg "
    ),
    Event(
        id: UUID(),
        category: [.all, .festivals],
        title: "OpenSpacePicnic",
        content: "Пикник в дворике нового корпуса НГУ посвящённый дню знаний.",
        startDate: "2024-12-01",
        endDate: "2024-12-02",
        location: "Академгородок, ул. Пирогова, 1",
        posterUrl: "https://static.tildacdn.com/tild3230-3163-4439-b733-366633643931/DSC_4453.jpg"
    ),
    Event(
        id: UUID(),
        category: [.all, .meetings],
        title: "День открытых дверей в НГУ",
        content: "Выставка факультетов, общение со студентами и многое другое.",
        startDate: "2024-12-01",
        endDate: "2024-12-02",
        location: "Академгородок, ул. Пирогова, 1",
        posterUrl: "https://static.tildacdn.com/tild3337-6465-4835-a130-623838656562/1680900--------2.jpg"
    ),
    Event(
        id: UUID(),
        category: [.all, .shows],
        title: "ХАХА BATTLE НГУ",
        content: "Самое смешное юмористическое соревнование в Академгородке.",
        startDate: "2024-11-15",
        endDate: "2024-11-15",
        location: "Академгородок, Проспект Строителей, 21",
        posterUrl: "https://sun9-12.userapi.com/Tjc3E_Yysjm5NfzuxndPMHgTXAO1S7T6-Ks87Q/iSYEIaVpiX4.jpg"
    ),
    Event(
        id: UUID(),
        category: [.all, .music],
        title: "3 дня дождя",
        content: "Концерт группы 3 дня дождя",
        startDate: "2024-11-13",
        endDate: "2024-11-13",
        location: "Новосибирск, Локомотив-Арена",
        posterUrl: "https://geopro-photos.storage.yandexcloud.net/resize_cache/48245238/e14e74968349be09ee1354fc509cee5d/iblock/aea/aeabbb2f275ef6812990534d33cb64d2/photo_2024_08_29-00.27.34.jpeg"
    ),
    Event(
        id: UUID(),
        category: [.all, .shows],
        title: "Андрей Бебуришвили",
        content: "Стендап 18+",
        startDate: "2025-02-15",
        endDate: "2025-02-15",
        location: "Новосибирск, ККК им.Маяковского",
        posterUrl: "https://live.mts.ru/image/full/505d782c-73eb-2170-a0e5-b28853d839b0.jpg"
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
        posterUrl: "https://images.iptv.rt.ru/images/cvj4k3rir4sqiatdopl0.jpg"
    )
]

let mockUserList = [
    User(id: UUID(), name: "Denis"),
    User(id: UUID(), name: "Mark")
]

let mockOrganization = Organization(
    id: UUID(),
    name: "NSU",
    coverUrl: "https://sesc.nsu.ru/upload/resize_cache/iblock/b4c/919_517_2/%D0%9D%D0%93%D0%A3.jpg",
    description: "НГУ - классический университет в Новосибирске, известный своей тесной интеграцией с научными институтами Сибирского отделения РАН. Университет предлагает высшее образование на 6 факультетах и в 4 институтах, сочетая естественнонаучные, инженерные и гуманитарные направления.",
    address: "г. Новосибирск, ул. Пирогова, д. 1",
    admins: mockUserList,
    images: [
        "https://ksonline.ru/wp-content/uploads/2022/05/NSU.jpg",
        "https://ksonline.ru/wp-content/uploads/2017/03/ngu.jpg"
    ],
    events: mockEventList
)
