//
//  MainPage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import SwiftUI

struct MainPage: View {
    @StateObject private var viewModel = EventsViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List(viewModel.events) { event in
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
            .onAppear {
                if viewModel.events.isEmpty {
                    viewModel.loadEvents()
                }
            }
        }
    }
}

#Preview {
    MainPage()
}
