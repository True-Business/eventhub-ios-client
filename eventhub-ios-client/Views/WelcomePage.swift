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
    @State private var showRegistration: Bool = false
    @State private var showError: Bool = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    
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
                
                GradientButton(title: "Войти", textColor: .black) {
                    if email.isValidEmail && !password.isEmpty {
                        authViewModel.login(email: email, password: password)
                    } else {
                        authViewModel.errorMessage = nil
                        showError = true
                    }
                }
                .disabled(authViewModel.loading)

                if authViewModel.loading {
                    ProgressView()
                }
                
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
                
                
                GradientButton(title: "Зарегистрироваться", textColor: .black, colorOpacity: 0.5) {
                    showRegistration = true
                }
                                
                Button(action: {
                    authViewModel.loginAnonymously()
                }) {
                    Text("Войти анонимно")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .navigationDestination(isPresented: $authViewModel.isLoggedIn) {
                MainPage()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $showRegistration) {
                    RegistrationCredentialsPage()
                        .navigationBarBackButtonHidden(true)
                }
            .alert("Ошибка", isPresented: $showError) {
                Button("Ок", role: .cancel) {
                    authViewModel.errorMessage = nil
                }
            } message: {
                Text(authViewModel.errorMessage ?? "Введите корректный email и пароль")
            }
            .onChange(of: authViewModel.errorMessage) { _, newValue in
                showError = newValue != nil
            }
        }
    }
}

//#Preview {
//    WelcomePage()
//        .environmentObject(AuthViewModel())
//}
