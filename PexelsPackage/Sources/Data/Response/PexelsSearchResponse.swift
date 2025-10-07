//
//  PexelsSearchResponse.swift
//  PexelsPackage
//
//  Created by air2 on 2025/10/07.
//

import Foundation

// 検索結果
public struct PexelsSearchResponse: Codable, Sendable {
    public let page: Int
    public let perPage: Int
    public let photos: [PexelsPhoto]
    public let totalResults: Int
    public let nextPage: String?

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case photos
        case totalResults = "total_results"
        case nextPage = "next_page"
    }
}
