//
//  BottomBarButton.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import SwiftUI

struct BottomBarButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 24, height: 24)
            Text(label)
                .font(.caption)
        }
    }
}
