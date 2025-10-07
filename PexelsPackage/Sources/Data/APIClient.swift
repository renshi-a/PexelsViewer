//
//  File.swift
//  PexelsPackage
//
//  Created by air2 on 2025/10/07.
//

import ComposableArchitecture
import Foundation
import Alamofire

@DependencyClient
public struct PexelsAPIClient: Sendable {
    // 初期化する
    public var initialize: @Sendable (String) -> Void
    // 写真を検索する
    public var searchPhotos: @Sendable (SearchPhotosRequest) async throws -> PexelsSearchResponse
}

extension PexelsAPIClient: DependencyKey {
    public static var liveValue: Self {
        let apiKey = LockIsolated("")
        let baseURL = URL(string: "https://api.pexels.com/v1")!
        let session = Session.default
        
        return Self(
            initialize: { key in
                apiKey.setValue(key)
            },
            searchPhotos: { request in
                try await performRequest(
                    path: request.path,
                    method: request.method,
                    queryParameters: request.queryParameters,
                    baseURL: baseURL,
                    apiKey: apiKey.value,
                    session: session
                )
            }
        )
    }
    
    private static func performRequest<T: Decodable & Sendable>(
        path: String,
        method: HTTPMethod,
        queryParameters: [String: Any]?,
        baseURL: URL,
        apiKey: String,
        session: Session
    ) async throws -> T {
        var url = baseURL.appendingPathComponent(path)
        
        if let queryParams = queryParameters {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = queryParams.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
            if let urlWithQuery = components?.url {
                url = urlWithQuery
            }
        }
        
        let headers: HTTPHeaders = [
            "Authorization": apiKey
        ]
        
        let response = await session.request(
            url,
            method: method,
            headers: headers
        )
        .validate()
        .serializingDecodable(T.self)
        .response
        
        switch response.result {
        case .success(let data):
            return data
            
        case .failure(let error):
            throw error
        }
    }
}

extension DependencyValues {
    public var pexelsAPIClient: PexelsAPIClient {
        get { self[PexelsAPIClient.self] }
        set { self[PexelsAPIClient.self] = newValue }
    }
}
