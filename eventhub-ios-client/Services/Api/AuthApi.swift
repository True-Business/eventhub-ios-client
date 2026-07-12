//
//  AuthApi.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 27.09.2025.
//
import Alamofire
import Foundation

protocol AuthApi {
    func login(dto: UserCredentialsRegistrationDto, completion: @escaping (Result<LoginUserDto, AFError>) -> Void)
    
    func preRegister(dto: UserCredentialsRegistrationDto, completion: @escaping (Result<RegistrationResponseDto, AFError>) -> Void)
    
    func sendConfirmationCode(userId: String, completion: @escaping (Result<Void, AFError>) -> Void)
    
    func verifyConfirmationCode(code: String, completion: @escaping (Result<RegistrationResponseDto, AFError>) -> Void)
    
    func postRegister(email: String, password: String, dto: UserInfoRegistrationDto, completion: @escaping (Result<RegistrationResponseDto, AFError>) -> Void)
}

class AuthApiImpl: AuthApi {
    private let session: Session
    private let baseURL: String
    
    init(config: AlamofireConfig = .shared) {
        self.session = config.makeSession()
        self.baseURL = config.getBaseUrl()
    }

    func login(dto: UserCredentialsRegistrationDto, completion: @escaping (Result<LoginUserDto, AFError>) -> Void) {
        let url = baseURL + "api/v1/auth/login"
        session.request(url,
                        method: .post,
                        parameters: dto,
                        encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: LoginUserDto.self) { response in
                self.logResponse(response, name: "login")
                completion(response.result)
            }
    }
    
    func preRegister(dto: UserCredentialsRegistrationDto, completion: @escaping (Result<RegistrationResponseDto, AFError>) -> Void) {
        
        let url = baseURL + "api/v1/auth"
        session.request(url,
                        method: .post,
                        parameters: dto,
                        encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: RegistrationResponseDto.self) { response in
                self.logResponse(response, name: "preRegister")
                completion(response.result)
            }
    }
    
    func sendConfirmationCode(userId: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        
        let url = baseURL + "api/v1/auth/send-code/\(userId)"
        session.request(url, method: .put)
            .validate()
            .response { response in
                self.logResponse(response, name: "sendConfirmationCode")
                completion(response.result.map { _ in () })
            }
    }
    
    func verifyConfirmationCode(code: String, completion: @escaping (Result<RegistrationResponseDto, AFError>) -> Void) {
        
        let url = baseURL + "api/v1/auth/check-code/\(code)"
        session.request(url, method: .put)
            .validate()
            .responseDecodable(of: RegistrationResponseDto.self) { response in
                self.logResponse(response, name: "verifyConfirmationCode")
                completion(response.result)
            }
    }
    
    func postRegister(email: String, password: String, dto: UserInfoRegistrationDto, completion: @escaping (Result<RegistrationResponseDto, AFError>) -> Void) {
        let url = baseURL + "api/v1/auth/add-info"
        session.request(url,
                        method: .post,
                        parameters: dto,
                        encoder: JSONParameterEncoder.default)
            .authenticate(username: email, password: password)
            .validate()
            .responseDecodable(of: RegistrationResponseDto.self) { response in
                self.logResponse(response, name: "postRegister")
                completion(response.result)
            }
    }

    private func logResponse<Value>(_ response: DataResponse<Value, AFError>, name: String) {
        #if DEBUG
        let request = response.request
        let method = request?.httpMethod ?? "?"
        let url = request?.url?.absoluteString ?? "?"
        let statusCode = response.response.map { String($0.statusCode) } ?? "no status"

        print("[AuthApi] \(name) request: \(method) \(url)")

        if let headers = request?.allHTTPHeaderFields, !headers.isEmpty {
            print("[AuthApi] \(name) request headers: \(redactedHeaders(headers))")
        }

        if let body = request?.httpBody {
            print("[AuthApi] \(name) request body: \(redactedBody(body))")
        }

        print("[AuthApi] \(name) response status: \(statusCode)")

        if let data = response.data {
            print("[AuthApi] \(name) response body: \(bodyString(data))")
        } else {
            print("[AuthApi] \(name) response body: <empty>")
        }

        if case .failure(let error) = response.result {
            print("[AuthApi] \(name) error: \(error.localizedDescription)")
        }
        #endif
    }

    private func redactedHeaders(_ headers: [String: String]) -> [String: String] {
        headers.mapValues { value in
            value.lowercased().hasPrefix("basic ") ? "<redacted>" : value
        }
    }

    private func redactedBody(_ data: Data) -> String {
        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            JSONSerialization.isValidJSONObject(object)
        else {
            return bodyString(data)
        }

        let redactedObject = redactSensitiveFields(in: object)
        guard
            let redactedData = try? JSONSerialization.data(withJSONObject: redactedObject, options: [.prettyPrinted, .sortedKeys]),
            let string = String(data: redactedData, encoding: .utf8)
        else {
            return bodyString(data)
        }

        return string
    }

    private func redactSensitiveFields(in object: Any) -> Any {
        if let dictionary = object as? [String: Any] {
            return dictionary.mapValues { value in
                redactSensitiveFields(in: value)
            }.reduce(into: [String: Any]()) { result, pair in
                let key = pair.key
                result[key] = key.lowercased().contains("password") ? "<redacted>" : pair.value
            }
        }

        if let array = object as? [Any] {
            return array.map(redactSensitiveFields)
        }

        return object
    }

    private func bodyString(_ data: Data) -> String {
        guard !data.isEmpty else {
            return "<empty>"
        }

        return String(data: data, encoding: .utf8) ?? "<non-utf8 body: \(data.count) bytes>"
    }
}
