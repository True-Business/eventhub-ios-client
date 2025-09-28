//
//  AuthViewModel.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    
    @Published private(set) var state = AuthState()
        
    private let authRepository: AuthRepository
    private var cancellables = Set<AnyCancellable>()
    
    // Ключи для UserDefaults
    private enum Keys {
        static let email = "email"
        static let password = "password"
        static let userId = "user_id"
        static let username = "username"
        static let shortId = "short_id"
        static let isLoggedIn = "is_logged_in"
    }
    
    private let defaults = UserDefaults.standard
    
    init(authRepository: AuthRepository = AuthRepository()) {
        self.authRepository = authRepository
        
        self.state.isLoggedIn = defaults.bool(forKey: Keys.isLoggedIn)
        self.state.currentUserEmail = defaults.string(forKey: Keys.email)
    }
    
    var isLoggedInBinding: Binding<Bool> {
        Binding(
            get: { self.state.isLoggedIn },
            set: { _ in } // внешне менять состояние не даём
        )
    }
    
    func login(email: String, password: String) {
        print("Логинимся с email=\(email), password=\(password)")
        
        
    }
    
    func logout() {
        
    }
    
    func preRegister(email: String, password: String, onPending: @escaping (RegistrationResponseDto?) -> Void = { _ in }) {
        
        state.loading = true
        
        authRepository.preRegister(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.state.loading = false
                
                switch result {
                case .success(let response):
                    onPending(response)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func sendCode(userId: String) {
        
        if userId == "" {
            print("Error: userId is empty!")
            return
        }
        
        print("Sending email verification code for userId: \(userId)")
        authRepository.sendCode(userId: userId) { _ in }
    }
    
    func verifyEmailVerificationCode(code: String, onSuccess: @escaping (String?) -> Void = { _ in }) {
        
        state.loading = true
                
        authRepository.verifyCode(code: code) { [weak self] result in
            DispatchQueue.main.async {
                self?.state.loading = false
                switch result {
                case .success(let res):
                    onSuccess(res.id)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func postRegister(userId: String, email: String, username: String, shortId: String, completion: @escaping (String?) -> Void) {
        state.loading = true
            
        authRepository.postRegister(id: userId, username: username, shortId: shortId) { [weak self] result in
            DispatchQueue.main.async {
                self?.state.loading = false
                switch result {
                case .success(let res):
                    self?.state.currentUserId = res.id
                    self?.state.username = username
                    self?.state.userShortId = shortId
                    self?.state.currentUserEmail = email
                    self?.state.isLoggedIn = true
                    self?.state.loading = false
                    
                    self?.addCredentialsToUserDefaults(userId: res.id, email: email, username: username, shortId: shortId)

                    completion(res.id)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func addCredentialsToUserDefaults(userId: String, email: String, username: String, shortId: String) {
        defaults.set(username, forKey: "username")
        defaults.set(email, forKey: "email")
        defaults.set(userId, forKey: "userId")
        defaults.set(shortId, forKey: "shortId")
    }
}

struct AuthState {
    var currentUserId: String? = nil
    var username: String? = nil
    var password: String? = nil
    var currentUserEmail: String? = nil
    var userShortId: String? = nil
    var isLoggedIn: Bool = false
        
    var loading: Bool = false
}
