//
//  WelcomePage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import SwiftUI

struct WelcomePage: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showMain: Bool = false
    @State private var showRegistration: Bool = false
    @State private var showError: Bool = false
    
    @ObservedObject var authViewModel: AuthViewModel
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Event Hub")
                    .font(.title)
                    .padding(.bottom, 8)
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .frame(maxWidth: 350)
                    .cornerRadius(8)
                
                SecureField("Пароль", text: $password)
                    .frame(maxWidth: 320)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                Button(action: {
                    if isValidEmail(email) && !password.isEmpty {
                        authViewModel.login(email: email, password: password)
                        showMain = true
                    } else {
                        showError = true
                    }
                }) {
                    Text("Войти")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .frame(maxWidth: 350)
                
                HStack {
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray.opacity(0.3))
                    
                    Text("или")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray.opacity(0.3))
                }
                .frame(maxWidth: 300, maxHeight: 30)
                                
                Button("Зарегистрироваться") {
                    
                }
                .frame(maxWidth: 310)
                .padding()
                .background(Color.yellow.opacity(0.5))
                .foregroundColor(.black)
                .cornerRadius(8)
                                
                Button(action: {
                    showMain = true
                }) {
                    Text("Войти анонимно")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .navigationDestination(isPresented: $showMain) {
                MainPage()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}

#Preview {
    WelcomePage(authViewModel: AuthViewModel())
}
