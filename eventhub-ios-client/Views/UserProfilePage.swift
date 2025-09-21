//
//  UserProfilePage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 21.09.2025.
//
import SwiftUI

struct UserProfilePage: View {
    
    @Environment(\.presentationMode) var presentationMode

    @State private var aboutText: String = "Вы только что начали читать текст, который сейчас заканичваете читать."
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image("defaultAvatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .shadow(radius: 4)
            
            Text("John Doe")
                .font(.title2)
                .bold()
            Text("@hihihaha")
                .foregroundColor(.gray)
            
            Divider()
                .padding(.horizontal)
            
            Spacer().frame(height: 20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("О себе")
                    .font(.headline)
                
                if isEditing {
                    TextEditor(text: $aboutText)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                } else {
                    Text(aboutText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color.orange.opacity(0.09))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
                        
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.white]),
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        )
    }
}

#Preview {
    UserProfilePage()
}
