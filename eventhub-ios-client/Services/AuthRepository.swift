//
//  AuthRepository.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 27.09.2025.
//

import Foundation

class AuthRepository {
    private let authApi: AuthApi
    
    init(authApi: AuthApi = ApiProvider.shared.authApi) {
        self.authApi = authApi
    }
    
    func preRegister(email: String, password: String, completion: @escaping (Result<RegistrationResponseDto, Error>) -> Void) {
        
        let dto = UserCredentialsRegistrationDto(email: email, password: password)
        authApi.preRegister(dto: dto) { result in
            switch result {
                case .success(let response):
                    print("preRegister success: \(response)")
                
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    func sendCode(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        authApi.sendConfirmationCode(userId: userId) { result in
            completion(result.mapError { $0 })
        }
    }
    
    func verifyCode(code: String, completion: @escaping (Result<RegistrationResponseDto, Error>) -> Void) {
        
        authApi.verifyConfirmationCode(code: code) { result in
            switch result {
                case .success(let response):
                    print("verifyCode response: \(response)")
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    // TODO: здесь уже нужно передавать почту и пароль чтобы сделать запрос
    func postRegister(
        id: String,
        username: String,
        shortId: String,
        completion: @escaping (Result<RegistrationResponseDto, Error>) -> Void
    ) {
        print("Adding user personal info. id: \(id), username: \(username), shortId: \(shortId)")
        
        let dto = UserInfoRegistrationDto(id: id, username: username, shortId: shortId)
        authApi.postRegister(dto: dto) { result in
            switch result {
                case .success(let response):
                    print("postRegister response: \(response)")
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}
