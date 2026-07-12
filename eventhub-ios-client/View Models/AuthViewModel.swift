//
//  AuthViewModel.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.09.2025.
//
import SwiftUI


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
    @Published var errorMessage: String? = nil
        
    private let authRepository: AuthRepository
    private let defaults = UserDefaults.standard
    
    init(authRepository: AuthRepository = AuthRepository()) {
        self.authRepository = authRepository
        
        self.isLoggedIn = defaults.bool(forKey: Keys.isLoggedIn)
        self.currentUserEmail = defaults.string(forKey: Keys.email)
        self.currentUserId = defaults.string(forKey: Keys.userId)
        self.username = defaults.string(forKey: Keys.username)
        self.userShortId = defaults.string(forKey: Keys.shortId)
    }
    
    func login(email: String, password: String) {
        // TODO: подключить реальный API логина, когда backend будет готов.
        print("Login is not implemented yet for email=\(email)")
        errorMessage = "Вход по email пока не реализован"
    }
    
    func loginAnonymously() {
        isLoggedIn = true
    }
    
    func logout() {
        currentUserId = nil
        username = nil
        password = nil
        currentUserEmail = nil
        userShortId = nil
        isLoggedIn = false
        errorMessage = nil
        clearStoredCredentials()
    }
    
    func preRegister(email: String, password: String, onPending: @escaping (RegistrationResponseDto?) -> Void = { _ in }) {
        setLoading(true)
        
        authRepository.preRegister(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success(let response):
                    self?.errorMessage = nil
                    onPending(response)
                case .failure(let error):
                    self?.handle(error)
                    onPending(nil)
                }
            }
        }
    }
    
    func sendCode(userId: String) {
        
        if userId.isBlank {
            errorMessage = "Не удалось отправить код: пустой userId"
            return
        }
        
        print("Sending email verification code for userId: \(userId)")
        authRepository.sendCode(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                if case .failure(let error) = result {
                    self?.handle(error)
                }
            }
        }
    }
    
    func verifyEmailVerificationCode(code: String, onSuccess: @escaping (String?) -> Void = { _ in }) {
        setLoading(true)
                
        authRepository.verifyCode(code: code) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                switch result {
                case .success(let res):
                    self?.errorMessage = nil
                    onSuccess(res.id)
                case .failure(let error):
                    self?.handle(error)
                    onSuccess(nil)
                }
            }
        }
    }
    
    func postRegister(userId: String, email: String, password: String, username: String, shortId: String, completion: @escaping (String?) -> Void) {
        setLoading(true)
            
        authRepository.postRegister(id: userId, email: email, password: password, username: username, shortId: shortId) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                switch result {
                case .success(let res):
                    self?.saveSession(userId: res.id, email: email, username: username, shortId: shortId)
                    completion(res.id)
                case .failure(let error):
                    self?.handle(error)
                    completion(nil)
                }
            }
        }
    }
    
    private func saveSession(userId: String, email: String, username: String, shortId: String) {
        currentUserId = userId
        self.username = username
        userShortId = shortId
        currentUserEmail = email
        isLoggedIn = true
        errorMessage = nil

        defaults.set(username, forKey: Keys.username)
        defaults.set(email, forKey: Keys.email)
        defaults.set(userId, forKey: Keys.userId)
        defaults.set(shortId, forKey: Keys.shortId)
        defaults.set(true, forKey: Keys.isLoggedIn)
    }

    private func clearStoredCredentials() {
        [
            Keys.email,
            Keys.password,
            Keys.userId,
            Keys.username,
            Keys.shortId,
            Keys.isLoggedIn
        ].forEach(defaults.removeObject(forKey:))
    }

    private func setLoading(_ isLoading: Bool) {
        loading = isLoading
    }

    private func handle(_ error: Error) {
        errorMessage = error.localizedDescription
        print(error.localizedDescription)
    }
}
