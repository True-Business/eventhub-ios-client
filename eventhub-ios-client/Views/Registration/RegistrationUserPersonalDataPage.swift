//
//  RegistrationUserPersonalDataPage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 21.09.2025.
//

import SwiftUI

struct RegistrationUserPersonalDataPage: View {
    @State private var shortId: String = ""
    @State private var username: String = ""
    @State private var isShortIdValid: Bool = true
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateNext: Bool = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private let userId: String
    private let email: String
    private let password: String
    
    init(userId: String, email: String, password: String) {
        self.userId = userId
        self.email = email
        self.password = password
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Персональные данные")
                    .font(.title)
                    .padding(.bottom, 8)
                
                TextField("Как вас зовут", text: $username)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.6), lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity)
                
                HStack {
                    Text("@")
                        .foregroundColor(.gray)
                    TextField("Короткое имя (например, ivanov)", text: $shortId)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: shortId) { oldValue, newValue in
                            isShortIdValid = newValue.range(of: "^[a-zA-Z0-9]+$", options: .regularExpression) != nil
                        }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isShortIdValid ? Color.black : Color.red, lineWidth: 1)
                )
                
                if !isShortIdValid {
                    Text("Имя может содержать только буквы и цифры!")
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                }
                
                Spacer().frame(height: 24)
                
                GradientButton(title: "Продолжить", textColor: .white) {
                    if username.isBlank {
                        alertMessage = "Введите ваше имя!"
                        showAlert = true
                        return
                    }
                    
                    if shortId.isBlank || !isShortIdValid {
                        alertMessage = "Введите корректное коротке имя!"
                        showAlert = true
                        return
                    }
                    
                    authViewModel.postRegister(userId: userId, email: email, username: username, shortId: shortId) { res in
                        if res != nil {
                            navigateNext = true
                        } else {
                            alertMessage = "Не удалось сохранить данные! Попробуйте еще раз."
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateNext) {
                MainPage()
                    .navigationBarBackButtonHidden(true)
            }
            .padding(24)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("Ок")))
            }
        }
    }
}

extension String {
    var isBlank: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}


#Preview {
    RegistrationUserPersonalDataPage(userId: "", email: "", password: "")
}
