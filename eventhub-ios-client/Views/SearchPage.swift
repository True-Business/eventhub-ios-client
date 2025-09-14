//
//  SearchPage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import SwiftUI

struct SearchPage: View {
    
    @ObservedObject var eventsViewModel: EventsViewModel = EventsViewModel()
    
    @State private var searchQuery: String = ""
    
    /*
        presentationMode - это состояние среды, представляемое SwiftUI. Оно содержит текущий реим показа (pushed/presented).
        Через него можно закрывать экран, это аналог navController.popBackStack() из Jetpack Compose
     */
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                        .padding()
                }
                            
                Spacer()
            
                Text("Поиск")
                    .font(.headline)
                            
                Spacer()
                            
                // Пустой view, чтобы центрировать заголовок
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 44, height: 44)
            }
            .background(Color.white)
            
            TextField("Поиск мероприятий...", text: $searchQuery)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(white: 0.95))
                .cornerRadius(25)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .onChange(of: searchQuery) { oldValue, newValue in
                    if newValue.count > 2 {
                        eventsViewModel.searchEvents(query: newValue)
                    }
                }
            
            if eventsViewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                List(eventsViewModel.events) { event in
                    EventCard(event: event)
                        .onTapGesture {
                            // TODO: (e.vartazaryan 14.09.2025) сделать логику перехода на страницу мероприятия
                        }
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 4)
                }
                .listStyle(PlainListStyle())
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    SearchPage()
}
