//
//  AuthViewModel.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import SwiftUI

class AuthViewModel: ObservableObject {
    
    func login(email: String, password: String) {
        print("Логинимся с email=\(email), password=\(password)")
        //TODO(e.vartazaryan 14.09.2025): сделать интеграцию с беком
    }
}
