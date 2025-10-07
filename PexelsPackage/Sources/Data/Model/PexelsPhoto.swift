//
//  File.swift
//  PexelsPackage
//
//  Created by air2 on 2025/10/07.
//

import Foundation

// Photoオブジェクト
public struct PexelsPhoto: Codable, Sendable, Identifiable {
    public let id: Int
    public let width: Int
    public let height: Int
    public let url: String
    public let photographer: String
    public let photographerUrl: String
    public let photographerId: Int
    public let avgColor: String
    public let src: PexelsPhotoSource
    public let liked: Bool
    public let alt: String
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, url, photographer
        case photographerUrl = "photographer_url"
        case photographerId = "photographer_id"
        case avgColor = "avg_color"
        case src, liked, alt
    }
}

// PhotoSrc
public struct PexelsPhotoSource: Codable, Sendable {
    public let original: String
    public let large2x: String
    public let large: String
    public let medium: String
    public let small: String
    public let portrait: String
    public let landscape: String
    public let tiny: String
    
    enum CodingKeys: String, CodingKey {
        case original
        case large2x = "large2x"
        case large, medium, small, portrait, landscape, tiny
    }
}
