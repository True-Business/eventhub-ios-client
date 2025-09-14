//
//  MainPage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import SwiftUI

struct MainPage: View {
    
    @State private var events: [Event] = [
            Event(id: 1, title: "Событие 1", description: "Описание события 1"),
            Event(id: 2, title: "Событие 2", description: "Описание события 2")
        ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List(events) { event in
                    EventCard(event: event)
                        .listRowInsets(EdgeInsets())
                        .onTapGesture {
                            print("Navigate to event \(event.id)")
                        }
                }
                .listStyle(PlainListStyle())
                    
                // Bottom Bar
                HStack {
                    Spacer()
                    BottomBarButton(icon: "house.fill", label: "Лента")
                    Spacer()
                    BottomBarButton(icon: "magnifyingglass", label: "Поиск")
                    Spacer()
                    BottomBarButton(icon: "person.fill", label: "Друзья")
                    Spacer()
                    BottomBarButton(icon: "gearshape.fill", label: "Настройки")
                    Spacer()
                }
                .padding()
                .background(Color.white)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

#Preview {
    MainPage()
}
