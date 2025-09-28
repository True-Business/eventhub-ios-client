//
//  AuthApi.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 27.09.2025.
//
import Alamofire

protocol AuthApi {
    
    func preRegister(dto: UserCredentialsRegistrationDto, completion: @escaping (Result<RegistrationResponseDto, AFError>) -> Void)
    
    func sendConfirmationCode(userId: String, completion: @escaping (Result<Void, AFError>) -> Void)
    
    func verifyConfirmationCode(code: String, completion: @escaping (Result<RegistrationResponseDto, AFError>) -> Void)
    
    func postRegister(dto: UserInfoRegistrationDto, completion: @escaping (Result<RegistrationResponseDto, AFError>) -> Void)
}

class AuthApiImpl: AuthApi {
    private let session: Session
    private let baseURL: String
    
    init(config: AlamofireConfig = .shared) {
        self.session = config.makeSession()
        self.baseURL = config.getBaseUrl()
    }
    
    func preRegister(dto: UserCredentialsRegistrationDto, completion: @escaping (Result<RegistrationResponseDto, AFError>) -> Void) {
        
        let url = baseURL + "api/v1/auth"
        session.request(url,
                        method: .post,
                        parameters: dto,
                        encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: RegistrationResponseDto.self) { response in
                completion(response.result)
            }
    }
    
    func sendConfirmationCode(userId: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        
        let url = baseURL + "api/v1/auth/send-code/\(userId)"
        session.request(url, method: .put)
            .validate()
            .response { response in
                completion(response.result.map { _ in () })
            }
    }
    
    func verifyConfirmationCode(code: String, completion: @escaping (Result<RegistrationResponseDto, AFError>) -> Void) {
        
        let url = baseURL + "api/v1/auth/check-code/\(code)"
        session.request(url, method: .put)
            .validate()
            .responseDecodable(of: RegistrationResponseDto.self) { response in
                completion(response.result)
            }
    }
    
    func postRegister(dto: UserInfoRegistrationDto, completion: @escaping (Result<RegistrationResponseDto, AFError>) -> Void) {
        let url = baseURL + "api/v1/auth/add-info"
        session.request(url,
                        method: .post,
                        parameters: dto,
                        encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: RegistrationResponseDto.self) { response in
                completion(response.result)
            }
    }
}
