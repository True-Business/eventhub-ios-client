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
            EventPosterImage(urlString: event.posterUrl, height: 180)

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

struct EventPosterImage: View {
    let urlString: String
    let height: CGFloat

    var body: some View {
        let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines))

        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure, .empty:
                ZStack {
                    Color.gray.opacity(0.18)
                    Image(systemName: "photo")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.gray.opacity(0.7))
                }
            @unknown default:
                Color.gray.opacity(0.18)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
    }
}
