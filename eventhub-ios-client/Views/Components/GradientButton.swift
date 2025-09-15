//  Общий переиспользуемый компнент кнопки с градиентом оранжевого
//
//  GradientButton.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 16.09.2025.
//

import SwiftUI

struct GradientButton: View {
    let title: String
    var textColor: Color = .white
    var colorOpacity: Double = 1.0
    var gradientColors: [Color] = [
        Color(red: 1.0, green: 0.38, blue: 0.0), // оранжево-красный (#FF6100)
        Color(red: 1.0, green: 0.65, blue: 0.0)  // яркий оранжевый (#FFA500)
    ]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .opacity(colorOpacity)
                )
                .cornerRadius(8)
        }
        .frame(maxWidth: 350)
    }
}
