//
//  SearchBar.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 21.09.2025.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var onCancel: () -> Void
    
    var body: some View {
        HStack {
            TextField("Поиск мероприятий...", text: $text)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .frame(maxWidth: .infinity)
            
            Button(action: onCancel) {
                Text("Отмена")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}
