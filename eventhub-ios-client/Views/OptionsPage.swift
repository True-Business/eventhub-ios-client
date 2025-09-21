//
//  OptionsPage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 21.09.2025.
//
import SwiftUI

struct OptionsPage: View {
    
    @Environment(\.presentationMode) var presentationMode
    
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
            
            NavigationLink(destination: UserProfilePage()) {
                HStack {
                    Text("Мой профиль")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(1.0))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button("Выход из аккаунта") {
                    print("Logout tapped")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .clipShape(Capsule())
                
                Button("Удалить аккаунт") {
                    print("Delete tapped")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .clipShape(Capsule())
            }
            .padding(.horizontal)
            
            Spacer().frame(height: 20)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black) // черная стрелка
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
    OptionsPage()
}
