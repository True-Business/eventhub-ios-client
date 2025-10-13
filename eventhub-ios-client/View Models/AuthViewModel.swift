//
//  AuthViewModel.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import SwiftUI
import Combine


class AuthViewModel: ObservableObject {
    
    // Ключи для UserDefault
    private enum Keys {
        static let email = "email"
        static let password = "password"
        static let userId = "user_id"
        static let username = "username"
        static let shortId = "short_id"
        static let isLoggedIn = "is_logged_in"
    }
    
    @Published var currentUserId: String? = nil
    @Published var username: String? = nil
    @Published var password: String? = nil
    @Published var currentUserEmail: String? = nil
    @Published var userShortId: String? = nil
    @Published var isLoggedIn: Bool = false
        
    @Published var loading: Bool = false
        
    private let authRepository: AuthRepository
    private var cancellables = Set<AnyCancellable>()
    
    private let defaults = UserDefaults.standard
    
    init(authRepository: AuthRepository = AuthRepository()) {
        self.authRepository = authRepository
        
        self.isLoggedIn = defaults.bool(forKey: Keys.isLoggedIn)
        self.currentUserEmail = defaults.string(forKey: Keys.email)
    }
    
    func login(email: String, password: String) {
        print("Логинимся с email=\(email), password=\(password)")
        
        
    }
    
    func loginAnonymously() {
        isLoggedIn = true
    }
    
    func logout() {
        
    }
    
    func preRegister(email: String, password: String, onPending: @escaping (RegistrationResponseDto?) -> Void = { _ in }) {
        self.loading = true
        
        authRepository.preRegister(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.loading = false
                
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
        self.loading = true
                
        authRepository.verifyCode(code: code) { [weak self] result in
            DispatchQueue.main.async {
                self?.loading = false
                switch result {
                case .success(let res):
                    onSuccess(res.id)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func postRegister(userId: String, email: String, password: String, username: String, shortId: String, completion: @escaping (String?) -> Void) {
        self.loading = true
            
        authRepository.postRegister(id: userId, email: email, password: password, username: username, shortId: shortId) { [weak self] result in
            DispatchQueue.main.async {
                self?.loading = false
                switch result {
                case .success(let res):
                    self?.currentUserId = res.id
                    self?.username = username
                    self?.userShortId = shortId
                    self?.currentUserEmail = email
                    self?.isLoggedIn = true
                    self?.loading = false
                    
                    self?.addCredentialsToUserDefaults(userId: res.id, email: email, password: password, username: username, shortId: shortId)

                    completion(res.id)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func addCredentialsToUserDefaults(userId: String, email: String, password: String, username: String, shortId: String) {
        defaults.set(username, forKey: Keys.username)
        defaults.set(email, forKey: Keys.email)
        defaults.set(userId, forKey: Keys.userId)
        defaults.set(shortId, forKey: Keys.shortId)
        defaults.set(true, forKey: Keys.isLoggedIn)
    }
}
