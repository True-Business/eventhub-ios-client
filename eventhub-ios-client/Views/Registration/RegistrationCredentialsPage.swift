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
                    if isValidEmail(email) && !password.isEmpty && password == passwordCopy {
                        showEmailVerification = true
                    }
                }
                
                Spacer()
                
            }
            .padding(16)
            .navigationDestination(isPresented: $showEmailVerification) {
                RegistrationEmailVerificationPage(email: email)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    // Простейшая проверка email
    func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
}
