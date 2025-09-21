//
//  RegistrationEmailVerificationPage.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 21.09.2025.
//

import SwiftUI

struct RegistrationEmailVerificationPage: View {
    let email: String
    
    @State private var verificationCode: String = ""
    @State private var showError: Bool = false
    @State private var isResendEnabled: Bool = true
    @State private var countdown: Int = 60
    @State private var navigateNext: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Подтвердите email")
                    .font(.title)
                    .padding(.bottom, 16)
                
                Text("Мы отправили код на \(email)")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.bottom, 32)
                
                TextField("Код подтверждения", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(showError ? Color.red : Color.gray, lineWidth: 1)
                    )
                    .onChange(of: verificationCode) {
                        showError = false
                    }
                
                if showError {
                    Text("Неверный код подтверждения")
                        .foregroundColor(.red)
                }
                
                GradientButton(title: "Подтвердить", textColor: .white) {
                    if verificationCode.count == 4 {
                        // TODO: добавить логику проверки корректности введёного кода
                        navigateNext = true
                    } else {
                        showError = true
                    }
                }
                
                Button(action: {
                    if isResendEnabled {
                        // TODO: добавить логику повторной отправки кода
                        print("Код отправлен повторно")
                        isResendEnabled = false
                        countdown = 60
                    }
                }) {
                    Text(isResendEnabled ? "Отправить код повторно" : "Повторная отправка через \(countdown) сек")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .disabled(!isResendEnabled)
                
                Spacer()
            }
            .navigationDestination(isPresented: $navigateNext) {
                RegistrationUserPersonalDataPage()
                    .navigationBarBackButtonHidden(true)
            }
            .padding(24)
            .onReceive(timer) { _ in
                if !isResendEnabled && countdown > 0 {
                    countdown -= 1
                } else if countdown == 0 {
                    isResendEnabled = true
                }
            }
        }
    }
}
