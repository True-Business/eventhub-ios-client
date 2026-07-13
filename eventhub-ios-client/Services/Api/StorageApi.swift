//
//  StorageApi.swift
//  eventhub-ios-client
//
//  Created by Эдуард Вартазарян on 14.07.2026.
//

import Alamofire
import Foundation

protocol StorageApi {
    func genUploadUrls(
        request: ObjectUploadRequestDto,
        completion: @escaping (Result<ObjectUploadResponseDto, AFError>) -> Void
    )
    func upload(data: Data, to url: String, completion: @escaping (Result<Void, AFError>) -> Void)
    func confirmUpload(
        request: ObjectConfirmRequestDto,
        completion: @escaping (Result<ObjectConfirmResponseDto, AFError>) -> Void
    )
}

final class StorageApiImpl: StorageApi {
    private let session: Session
    private let baseURL: String

    init(config: AlamofireConfig = .shared) {
        self.session = config.makeSession()
        self.baseURL = config.getBaseUrl()
    }

    func genUploadUrls(
        request: ObjectUploadRequestDto,
        completion: @escaping (Result<ObjectUploadResponseDto, AFError>) -> Void
    ) {
        let url = baseURL + "api/v1/storage/urls"

        authenticatedRequest(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: ObjectUploadResponseDto.self) { response in
                self.logResponse(response, name: "genUploadUrls")
                completion(response.result)
            }
    }

    func upload(data: Data, to url: String, completion: @escaping (Result<Void, AFError>) -> Void) {
        session.upload(data, to: url, method: .put)
            .validate()
            .response { response in
                self.logResponse(response, name: "uploadObject")
                completion(response.result.map { _ in () })
            }
    }

    func confirmUpload(
        request: ObjectConfirmRequestDto,
        completion: @escaping (Result<ObjectConfirmResponseDto, AFError>) -> Void
    ) {
        let url = baseURL + "api/v1/storage/confirmed"

        authenticatedRequest(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: ObjectConfirmResponseDto.self) { response in
                self.logResponse(response, name: "confirmUpload")
                completion(response.result)
            }
    }

    private func authenticatedRequest<Parameters: Encodable, Encoder: ParameterEncoder>(
        _ url: String,
        method: HTTPMethod,
        parameters: Parameters?,
        encoder: Encoder
    ) -> DataRequest {
        let request = session.request(url, method: method, parameters: parameters, encoder: encoder)
        let defaults = UserDefaults.standard

        if
            let email = defaults.string(forKey: "email"),
            let password = defaults.string(forKey: "password"),
            !email.isEmpty,
            !password.isEmpty
        {
            return request.authenticate(username: email, password: password)
        }

        return request
    }

    private func logResponse<Value>(_ response: DataResponse<Value, AFError>, name: String) {
        #if DEBUG
        let method = response.request?.httpMethod ?? "?"
        let url = response.request?.url?.absoluteString ?? "?"
        let statusCode = response.response.map { String($0.statusCode) } ?? "no status"

        print("[StorageApi] \(name) request: \(method) \(url)")
        print("[StorageApi] \(name) response status: \(statusCode)")

        if let data = response.data, !data.isEmpty {
            print("[StorageApi] \(name) response body: \(String(data: data, encoding: .utf8) ?? "<non-utf8 body>")")
        }

        if case .failure(let error) = response.result {
            print("[StorageApi] \(name) error: \(error.localizedDescription)")
        }
        #endif
    }
}

