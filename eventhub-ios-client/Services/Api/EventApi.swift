//
//  EventApi.swift
//  eventhub-ios-client
//

import Alamofire
import Foundation

protocol EventApi {
    func getEvents(category: EventCategory?, completion: @escaping (Result<[EventDto], AFError>) -> Void)
    func searchEvents(filter: EventSearchFilterDto, completion: @escaping (Result<[EventDto], AFError>) -> Void)
    func createEvent(dto: EventCreateUpdateDto, completion: @escaping (Result<EventDto, AFError>) -> Void)
}

final class EventApiImpl: EventApi {
    private let session: Session
    private let baseURL: String

    init(config: AlamofireConfig = .shared) {
        self.session = config.makeSession()
        self.baseURL = config.getBaseUrl()
    }

    func getEvents(category: EventCategory?, completion: @escaping (Result<[EventDto], AFError>) -> Void) {
        let url = baseURL + "api/v1/event"
        let parameters = category == nil || category == .all ? nil : ["category": category?.rawValue ?? ""]

        authenticatedRequest(url, method: .get, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default)
            .validate()
            .responseDecodable(of: [EventDto].self) { response in
                self.logResponse(response, name: "getEvents")
                completion(response.result)
            }
    }

    func searchEvents(filter: EventSearchFilterDto, completion: @escaping (Result<[EventDto], AFError>) -> Void) {
        let url = baseURL + "api/v1/event/search"

        authenticatedRequest(url, method: .post, parameters: filter, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: [EventDto].self) { response in
                self.logResponse(response, name: "searchEvents")
                completion(response.result)
            }
    }

    func createEvent(dto: EventCreateUpdateDto, completion: @escaping (Result<EventDto, AFError>) -> Void) {
        let url = baseURL + "api/v1/event"

        authenticatedRequest(url, method: .post, parameters: dto, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: EventDto.self) { response in
                self.logResponse(response, name: "createEvent")
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

        print("[EventApi] \(name) request: \(method) \(url)")
        print("[EventApi] \(name) response status: \(statusCode)")

        if let data = response.data, !data.isEmpty {
            print("[EventApi] \(name) response body: \(String(data: data, encoding: .utf8) ?? "<non-utf8 body>")")
        }

        if case .failure(let error) = response.result {
            print("[EventApi] \(name) error: \(error.localizedDescription)")
        }
        #endif
    }
}
