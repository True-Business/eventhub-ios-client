//
//  FriendsApi.swift
//  eventhub-ios-client
//

import Alamofire
import Foundation

protocol FriendsApi {
    func getFriends(userId: UUID, completion: @escaping (Result<[UserDto], AFError>) -> Void)
    func getUser(userId: UUID, completion: @escaping (Result<UserDto, AFError>) -> Void)
    func searchUsers(filter: FindUsersRequestDto, completion: @escaping (Result<[UserDto], AFError>) -> Void)
    func sendFriendRequest(dto: CreateFriendRequestDto, completion: @escaping (Result<FriendRequestDto, AFError>) -> Void)
    func getIncomingRequests(userId: UUID, completion: @escaping (Result<[FriendRequestDto], AFError>) -> Void)
    func acceptFriendRequest(dto: AcceptFriendRequestDto, completion: @escaping (Result<Void, AFError>) -> Void)
    func rejectFriendRequest(requestId: UUID, completion: @escaping (Result<Void, AFError>) -> Void)
}

final class FriendsApiImpl: FriendsApi {
    private let session: Session
    private let baseURL: String

    init(config: AlamofireConfig = .shared) {
        self.session = config.makeSession()
        self.baseURL = config.getBaseUrl()
    }

    func getFriends(userId: UUID, completion: @escaping (Result<[UserDto], AFError>) -> Void) {
        let url = baseURL + "api/v1/friend/list/\(userId.uuidString)"

        authenticatedRequest(url, method: .get, parameters: Optional<String>.none, encoder: URLEncodedFormParameterEncoder.default)
            .validate()
            .responseDecodable(of: [UserDto].self) { response in
                self.logResponse(response, name: "getFriends")
                completion(response.result)
            }
    }

    func getUser(userId: UUID, completion: @escaping (Result<UserDto, AFError>) -> Void) {
        let url = baseURL + "api/v1/user/\(userId.uuidString)"

        authenticatedRequest(url, method: .get, parameters: Optional<String>.none, encoder: URLEncodedFormParameterEncoder.default)
            .validate()
            .responseDecodable(of: UserDto.self) { response in
                self.logResponse(response, name: "getUser")
                completion(response.result)
            }
    }

    func searchUsers(filter: FindUsersRequestDto, completion: @escaping (Result<[UserDto], AFError>) -> Void) {
        let url = baseURL + "api/v1/user/search"

        authenticatedRequest(url, method: .post, parameters: filter, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: [UserDto].self) { response in
                self.logResponse(response, name: "searchUsers")
                completion(response.result)
            }
    }

    func sendFriendRequest(dto: CreateFriendRequestDto, completion: @escaping (Result<FriendRequestDto, AFError>) -> Void) {
        let url = baseURL + "api/v1/friend/request/send"

        authenticatedRequest(url, method: .post, parameters: dto, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: FriendRequestDto.self) { response in
                self.logResponse(response, name: "sendFriendRequest")
                completion(response.result)
            }
    }

    func getIncomingRequests(userId: UUID, completion: @escaping (Result<[FriendRequestDto], AFError>) -> Void) {
        let url = baseURL + "api/v1/friend/request/incoming/\(userId.uuidString)"

        authenticatedRequest(url, method: .get, parameters: Optional<String>.none, encoder: URLEncodedFormParameterEncoder.default)
            .validate()
            .responseDecodable(of: [FriendRequestDto].self) { response in
                self.logResponse(response, name: "getIncomingRequests")
                completion(response.result)
            }
    }

    func acceptFriendRequest(dto: AcceptFriendRequestDto, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "api/v1/friend/request/accept"

        authenticatedRequest(url, method: .post, parameters: dto, encoder: JSONParameterEncoder.default)
            .validate()
            .response { response in
                self.logResponse(response, name: "acceptFriendRequest")
                completion(response.result.map { _ in () })
            }
    }

    func rejectFriendRequest(requestId: UUID, completion: @escaping (Result<Void, AFError>) -> Void) {
        let url = baseURL + "api/v1/friend/request/\(requestId.uuidString)/decline"

        authenticatedRequest(url, method: .post, parameters: Optional<String>.none, encoder: URLEncodedFormParameterEncoder.default)
            .validate()
            .response { response in
                self.logResponse(response, name: "rejectFriendRequest")
                completion(response.result.map { _ in () })
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

        print("[FriendsApi] \(name) request: \(method) \(url)")
        print("[FriendsApi] \(name) response status: \(statusCode)")

        if let data = response.data, !data.isEmpty {
            print("[FriendsApi] \(name) response body: \(String(data: data, encoding: .utf8) ?? "<non-utf8 body>")")
        }

        if case .failure(let error) = response.result {
            print("[FriendsApi] \(name) error: \(error.localizedDescription)")
        }
        #endif
    }
}
