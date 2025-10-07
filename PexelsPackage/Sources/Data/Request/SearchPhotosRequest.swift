//
//  SearchPhotosRequest.swift
//  PexelsPackage
//
//  Created by air2 on 2025/10/07.
//

import Alamofire
import Foundation

// 検索リクエスト
public struct SearchPhotosRequest: Sendable {
    public let query: String
    public let page: Int
    public let perPage: Int
    public let orientation: String?
    public let size: String?
    public let color: String?
    public let locale: String?

    public init(
        query: String,
        page: Int = 1,
        perPage: Int = 15,
        orientation: String? = nil,
        size: String? = nil,
        color: String? = nil,
        locale: String? = nil
    ) {
        self.query = query
        self.page = page
        self.perPage = perPage
        self.orientation = orientation
        self.size = size
        self.color = color
        self.locale = locale
    }

    var path: String { "/search" }
    var method: HTTPMethod { .get }

    var queryParameters: [String: Any] {
        var params: [String: Any] = [
            "query": query,
            "page": page,
            "per_page": perPage
        ]
        if let orientation {
            params["orientation"] = orientation
        }
        if let size {
            params["size"] = size
        }
        if let color {
            params["color"] = color
        }
        if let locale {
            params["locale"] = locale
        }
        return params
    }
}
