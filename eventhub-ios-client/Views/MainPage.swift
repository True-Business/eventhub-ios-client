//
//  MainPage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import SwiftUI

struct MainPage: View {
    @StateObject private var viewModel = EventsViewModel()
    @State private var showSearch: Bool = false
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.events) { event in
                                NavigationLink(destination: EventPage(event: event)) {
                                    EventCard(event: event)
                                }
                                .buttonStyle(PlainButtonStyle()) // убираем эффект кнопки
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                        BottomBarButton(icon: "house.fill", label: "Главная")
                        Spacer()
                        BottomBarButton(icon: "person.2.fill", label: "Друзья")
                        Spacer()
                        BottomBarButton(icon: "calendar", label: "Мероприятия")
                        Spacer()
                        BottomBarButton(icon: "globe", label: "Организации")
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
                .blur(radius: showSearch ? 5 : 0)
                
                if showSearch {
                    VStack {
                        HStack {
                            SearchBar(text: $searchText) {
                                withAnimation {
                                    showSearch = false
                                    searchText = ""
                                    viewModel.searchResults.removeAll()
                                }
                            }
                            .onChange(of: searchText) { oldValue, newValue in
                                if !newValue.isEmpty {
                                    viewModel.searchEvents(query: newValue)
                                }
                            }
                        }
                        .padding()
                        
                        List(showSearch ? viewModel.searchResults : viewModel.events) { event in
                            EventCard(event: event)
                                .listRowInsets(EdgeInsets())
                        }
                        .listStyle(PlainListStyle())
                    }
                    .transition(.move(edge: .top))
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            withAnimation(.easeInOut) {
                                showSearch.toggle()
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                        .shadow(radius: 2)
                        .blur(radius: showSearch ? 5 : 0)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: OptionsPage()) {
                        Image("defaultAvatar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .shadow(radius: 2)
                            .blur(radius: showSearch ? 5 : 0)
                    }
                }
            }
        }
    }
}


#Preview {
    MainPage()
}
