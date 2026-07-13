//
//  StorageDtos.swift
//  eventhub-ios-client
//

import Foundation

struct ObjectUploadRequestDto: Encodable {
    let ownerId: String
    let ownerType: String
    let originNames: [String]
}

struct ObjectUploadResponseDto: Decodable {
    let urls: [ObjectUploadUrlInfoDto]
}

struct ObjectUploadUrlInfoDto: Decodable {
    let origin: String
    let id: String
    let url: String?
}

struct ObjectConfirmRequestDto: Encodable {
    let ownerId: String
    let ownerType: String
    let ids: [String]
}

struct ObjectConfirmResponseDto: Decodable {
    let files: [ObjectConfirmInfoDto]

    private enum CodingKeys: String, CodingKey {
        case statuses
        case files
        case confInfo
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        files = try container.decodeIfPresent([ObjectConfirmInfoDto].self, forKey: .statuses)
            ?? container.decodeIfPresent([ObjectConfirmInfoDto].self, forKey: .files)
            ?? container.decode([ObjectConfirmInfoDto].self, forKey: .confInfo)
    }
}

struct ObjectConfirmInfoDto: Decodable {
    let id: String
    let status: String
}
