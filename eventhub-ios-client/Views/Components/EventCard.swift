//
//  EventCard.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
//  Карточка мероприятия, которая показывается на главном экране
//

import SwiftUI

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: "https://picsum.photos/600/300?random=\(event.id)")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()
            } placeholder: {
                Color.gray
                    .frame(height: 180)
            }

            // Текстовая часть
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(event.location)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
