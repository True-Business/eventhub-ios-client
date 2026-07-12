//
//  RegistrationCredentialsPage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 21.09.2025.
//

import SwiftUI

struct RegistrationCredentialsPage: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordCopy: String = ""
    @State private var showEmailVerification: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var preRegisterResponse: RegistrationResponseDto? = nil
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.backward")
                            .foregroundColor(.blue)
                    }
                    Text("Добро пожаловать!")
                        .font(.system(size: 25, weight: .bold))
                        .padding(.leading, 8)
                    Spacer()
                }
                .padding(.vertical)
                
                Spacer().frame(height: 40)
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity)
                
                SecureField("Пароль", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity)
                
                SecureField("Повтор пароля", text: $passwordCopy)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity)
                
                Spacer().frame(height: 16)
                
                GradientButton(title: "Продолжить", textColor: .white) {
                    guard validateForm() else {
                        showError = true
                        return
                    }

                    authViewModel.preRegister(email: email, password: password) { response in
                        preRegisterResponse = response

                        guard response?.status == RegistrationStatus.pending.rawValue else {
                            errorMessage = response?.reason ?? "Не удалось начать регистрацию"
                            showError = true
                            return
                        }

                        authViewModel.sendCode(userId: response?.id ?? "")
                        showEmailVerification = true
                    }
                }
                
                Spacer()
                
            }
            .padding(16)
            .navigationDestination(isPresented: $showEmailVerification) {
                RegistrationEmailVerificationPage(userId: preRegisterResponse?.id ?? "", email: email, password: password)
                    .navigationBarBackButtonHidden(true)
            }
            .alert("Ошибка", isPresented: $showError) {
                Button("Ок", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func validateForm() -> Bool {
        if !email.isValidEmail {
            errorMessage = "Введите корректный email"
            return false
        }

        if password.isEmpty {
            errorMessage = "Введите пароль"
            return false
        }

        if password != passwordCopy {
            errorMessage = "Пароли не совпадают"
            return false
        }

        return true
    }
}
