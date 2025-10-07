//
//  PexelesSearchView.swift
//  PexelsPackage
//
//  Created by air2 on 2025/10/07.
//

import ComposableArchitecture
import Foundation
import PexelsModuleData
import SwiftUI

public struct PexelesSearchView: View {
    public init() {}

    public var body: some View {
        VStack {
            Text("PexelesSearchView")
        }
        .task {
            @Dependency(\.pexelsAPIClient) var apiClient
            do {
                let results = try await apiClient.searchPhotos(.init(query: "Flowers"))
                print(results)
            } catch {
                print("error: \(error)")
            }
        }
    }
}
