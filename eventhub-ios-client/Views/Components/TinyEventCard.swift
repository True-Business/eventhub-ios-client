//
//  TinyEventCard.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 13.10.2025.
//

import SwiftUI

struct TinyEventCard: View {
    let event: Event
    var withLabels: Bool = true
    var isEditing: Bool = false
    var onLockClick: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                // Постер организации
                EventPosterImage(urlString: event.posterUrl, height: 160)
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(radius: 5)
                
                // Кнопка блокировки в режиме редактирования
                if isEditing {
                    Button(action: onLockClick) {
                        Image(systemName: "lock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.accentColor)
                            .padding(16)
                            .background(Color.black.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .transition(.opacity)
                }
            }
            .frame(width: 160, height: 160)
            
            // Подписи
            if withLabels {
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.title)
                        .font(.system(size: 14, weight: .bold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(event.startDate)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
            }
        }
        .frame(width: 160)
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }
}
