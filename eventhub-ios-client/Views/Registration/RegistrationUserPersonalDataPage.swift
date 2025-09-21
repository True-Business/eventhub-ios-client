//
//  RegistrationUserPersonalDataPage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 21.09.2025.
//

import SwiftUI

struct RegistrationUserPersonalDataPage: View {
    @State private var displayName: String = ""
    @State private var username: String = ""
    @State private var isUsernameValid: Bool = true
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateNext: Bool = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Персональные данные")
                    .font(.title)
                    .padding(.bottom, 8)
                
                TextField("Как вас зовут", text: $displayName)
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
                    TextField("Короткое имя (например, ivanov)", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: username) { oldValue, newValue in
                            isUsernameValid = newValue.range(of: "^[a-zA-Z0-9]+$", options: .regularExpression) != nil
                        }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isUsernameValid ? Color.black : Color.red, lineWidth: 1)
                )
                
                if !isUsernameValid {
                    Text("Имя может содержать только буквы и цифры")
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                }
                
                Spacer().frame(height: 24)
                
                GradientButton(title: "Продолжить", textColor: .white) {
                    if displayName.isBlank {
                        alertMessage = "Введите ваше имя"
                        showAlert = true
                        return
                    }
                    if !isUsernameValid || username.isBlank {
                        alertMessage = "Некорректное имя пользователя"
                        showAlert = true
                        return
                    }
                    // TODO: сохранить данные
                    navigateNext = true
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
