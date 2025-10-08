//
//  PexelsSearchReducer.swift
//  PexelsPackage
//
//  Created by air2 on 2025/10/07.
//

import ComposableArchitecture
import Foundation
import PexelsModuleData

@Reducer
public struct PexelsSearchReducer: Sendable {
    @ObservableState
    public struct State: Equatable {
        // 検索語
        public var searchQuery: String = ""
        // Photoオブジェクト
        public var photos: [PexelsPhoto] = []
        // ローディング中か
        public var isLoading: Bool = false
        // エラーメッセージ
        public var errorMessage: String?
        // ページング中か
        public var isPaging: Bool = false
        // ページ
        public var currentPage: Int = 1
        // さらにページがあるか
        public var hasMorePages: Bool = true
        // 詳細
        public var selectedImageURL: URL?

        public init(
            searchQuery: String = "",
            photos: [PexelsPhoto] = [],
            isLoading: Bool = false,
            errorMessage: String? = nil,
            isPaging: Bool = false,
            currentPage: Int = 1,
            hasMorePages: Bool = true,
            selectedImageURL: URL? = nil
        ) {
            self.searchQuery = searchQuery
            self.photos = photos
            self.isLoading = isLoading
            self.errorMessage = errorMessage
            self.isPaging = isPaging
            self.currentPage = currentPage
            self.hasMorePages = hasMorePages
            self.selectedImageURL = selectedImageURL
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case searchQuerySubmitted
        case loadMorePhotos
        case searchResponse(TaskResult<PexelsSearchResponse>)
        case photoTapped(PexelsPhoto)
        case clearError
    }

    @Dependency(\.pexelsAPIClient) var pexelsClient

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .searchQuerySubmitted:
                guard !state.searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
                    return .none
                }

                state.isLoading = true
                state.errorMessage = nil
                state.currentPage = 1
                state.hasMorePages = true

                let query = state.searchQuery
                let request = SearchPhotosRequest(
                    query: query,
                    page: 1,
                    perPage: 20
                )

                return .run { send in
                    await send(.searchResponse(
                        TaskResult {
                            try await pexelsClient.searchPhotos(request)
                        }
                    ), animation: .easeInOut)
                }

            case .loadMorePhotos:
                guard !state.isPaging, state.hasMorePages, !state.searchQuery.isEmpty else {
                    return .none
                }

                state.isPaging = true
                state.currentPage += 1

                let query = state.searchQuery
                let page = state.currentPage
                let request = SearchPhotosRequest(
                    query: query,
                    page: page,
                    perPage: 20
                )

                return .run { send in
                    await send(.searchResponse(
                        TaskResult {
                            try await pexelsClient.searchPhotos(request)
                        }
                    ), animation: .easeInOut)
                }

            case let .searchResponse(.success(response)):
                state.isLoading = false
                state.isPaging = false

                if state.currentPage == 1 {
                    state.photos = response.photos
                } else {
                    state.photos.append(contentsOf: response.photos)
                }

                // ページネーション判定
                let totalPages = (response.totalResults + 19) / 20 // 切り上げ
                state.hasMorePages = state.currentPage < totalPages

                return .none

            case let .searchResponse(.failure(error)):
                state.isLoading = false
                state.isPaging = false

                state.errorMessage = "エラーが発生しました。再度やり直してください"
                return .none

            case let .photoTapped(photo):
                state.selectedImageURL = URL(string: photo.src.large2x)
                return .none

            case .clearError:
                state.errorMessage = nil
                return .none

            default:
                return .none
            }
        }
    }
}
