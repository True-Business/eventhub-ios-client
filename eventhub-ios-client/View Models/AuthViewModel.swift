//
//  AuthViewModel.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import SwiftUI

class AuthViewModel: ObservableObject {
    
    @Published var isLoggedIn: Bool = false
    @Published var isLoggedInAnonymously: Bool = false
    @Published var email: String = ""
    @Published var password: String = ""
    
    func login(email: String, password: String) {
        print("Логинимся с email=\(email), password=\(password)")
        //TODO(e.vartazaryan 14.09.2025): сделать интеграцию с беком
        
        self.email = email
        self.password = password
        self.isLoggedIn = true
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(password, forKey: "userPassword")
    }
    
    func logout() {
        isLoggedIn = false
        email = ""
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }
}
