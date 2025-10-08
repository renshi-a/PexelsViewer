import Testing
import Foundation
import ComposableArchitecture
@testable import PexelsModuleData
@testable import PexelsModuleFeature

struct TestError: Error, Equatable {
    let message: String
}

@Suite("PexelsSearchReducer Tests")
struct PexelsSearchReducerTests {
    
    @Test("クエリの更新")
    @MainActor
    func bindingAction() async {
        let store = TestStore(
            initialState: PexelsSearchReducer.State()
        ) {
            PexelsSearchReducer()
        }
        
        await store.send(.binding(.set(\.searchQuery, "mountains"))) {
            $0.searchQuery = "mountains"
        }
    }
    
    @Test("検索に成功")
    @MainActor
    func searchQuerySubmittedSuccess() async {
        let mockPhotos = [
            PexelsPhoto(
                id: 1,
                width: 1920,
                height: 1080,
                url: "https://example.com/photo1",
                photographer: "Test Photographer",
                photographerUrl: "https://example.com/photographer",
                photographerId: 123,
                avgColor: "#000000",
                src: PexelsPhotoSource(
                    original: "https://example.com/original",
                    large2x: "https://example.com/large2x",
                    large: "https://example.com/large",
                    medium: "https://example.com/medium",
                    small: "https://example.com/small",
                    portrait: "https://example.com/portrait",
                    landscape: "https://example.com/landscape",
                    tiny: "https://example.com/tiny"
                ),
                liked: false,
                alt: "Test photo"
            )
        ]
        
        let mockResponse = PexelsSearchResponse(
            page: 1,
            perPage: 20,
            photos: mockPhotos,
            totalResults: 100,
            nextPage: "https://example.com/page2"
        )
        
        let store = TestStore(
            initialState: PexelsSearchReducer.State(searchQuery: "任意のクエリ")
        ) {
            PexelsSearchReducer()
        } withDependencies: {
            $0.pexelsAPIClient.searchPhotos = { _ in mockResponse }
        }
        
        // 検索実施
        await store.send(.searchQuerySubmitted) {
            $0.isLoading = true
            $0.errorMessage = nil
            $0.currentPage = 1
            $0.hasMorePages = true
        }
        
        // 検索後
        await store.receive(\.searchResponse.success) {
            $0.isLoading = false
            $0.isPaging = false
            $0.photos = mockPhotos
            $0.hasMorePages = true
        }
    }
    
    @Test("検索に失敗")
    @MainActor
    func searchQuerySubmittedFailure() async {
        let store = TestStore(
            initialState: PexelsSearchReducer.State(searchQuery: "test")
        ) {
            PexelsSearchReducer()
        } withDependencies: {
            $0.pexelsAPIClient.searchPhotos = { _ in
                throw TestError(message: "Network error")
            }
        }
        
        await store.send(.searchQuerySubmitted) {
            $0.isLoading = true
            $0.errorMessage = nil
            $0.currentPage = 1
            $0.hasMorePages = true
        }
        
        await store.receive(\.searchResponse.failure) {
            $0.isLoading = false
            $0.isPaging = false
            $0.errorMessage = "エラーが発生しました。再度やり直してください"
        }
    }
    
    @Test("ページング成功")
    @MainActor
    func loadMorePhotosSuccess() async {
        let initialPhotos = [
            PexelsPhoto(
                id: 1,
                width: 1920,
                height: 1080,
                url: "https://example.com/photo1",
                photographer: "Photographer 1",
                photographerUrl: "https://example.com/photographer1",
                photographerId: 123,
                avgColor: "#000000",
                src: PexelsPhotoSource(
                    original: "https://example.com/original1",
                    large2x: "https://example.com/large2x1",
                    large: "https://example.com/large1",
                    medium: "https://example.com/medium1",
                    small: "https://example.com/small1",
                    portrait: "https://example.com/portrait1",
                    landscape: "https://example.com/landscape1",
                    tiny: "https://example.com/tiny1"
                ),
                liked: false,
                alt: "Photo 1"
            )
        ]
        
        let newPhotos = [
            PexelsPhoto(
                id: 2,
                width: 1920,
                height: 1080,
                url: "https://example.com/photo2",
                photographer: "Photographer 2",
                photographerUrl: "https://example.com/photographer2",
                photographerId: 456,
                avgColor: "#FFFFFF",
                src: PexelsPhotoSource(
                    original: "https://example.com/original2",
                    large2x: "https://example.com/large2x2",
                    large: "https://example.com/large2",
                    medium: "https://example.com/medium2",
                    small: "https://example.com/small2",
                    portrait: "https://example.com/portrait2",
                    landscape: "https://example.com/landscape2",
                    tiny: "https://example.com/tiny2"
                ),
                liked: false,
                alt: "Photo 2"
            )
        ]
        
        let mockResponse = PexelsSearchResponse(
            page: 2,
            perPage: 20,
            photos: newPhotos,
            totalResults: 100,
            nextPage: "https://example.com/page3"
        )
        
        let store = TestStore(
            initialState: PexelsSearchReducer.State(
                searchQuery: "nature",
                photos: initialPhotos,
                currentPage: 1,
                hasMorePages: true
            )
        ) {
            PexelsSearchReducer()
        } withDependencies: {
            $0.pexelsAPIClient.searchPhotos = { _ in mockResponse }
        }
        
        await store.send(.loadMorePhotos) {
            $0.isPaging = true
            $0.currentPage = 2
        }
        
        await store.receive(\.searchResponse.success) {
            $0.isLoading = false
            $0.isPaging = false
            $0.photos = initialPhotos + newPhotos
            $0.hasMorePages = true
        }
    }
    
    @Test("ページング失敗")
    @MainActor
    func loadMorePhotosFailure() async {
        let initialPhotos = [
            PexelsPhoto(
                id: 1,
                width: 1920,
                height: 1080,
                url: "https://example.com/photo1",
                photographer: "Photographer 1",
                photographerUrl: "https://example.com/photographer1",
                photographerId: 123,
                avgColor: "#000000",
                src: PexelsPhotoSource(
                    original: "https://example.com/original1",
                    large2x: "https://example.com/large2x1",
                    large: "https://example.com/large1",
                    medium: "https://example.com/medium1",
                    small: "https://example.com/small1",
                    portrait: "https://example.com/portrait1",
                    landscape: "https://example.com/landscape1",
                    tiny: "https://example.com/tiny1"
                ),
                liked: false,
                alt: "Photo 1"
            )
        ]
        
        let store = TestStore(
            initialState: PexelsSearchReducer.State(
                searchQuery: "nature",
                photos: initialPhotos,
                currentPage: 1,
                hasMorePages: true
            )
        ) {
            PexelsSearchReducer()
        } withDependencies: {
            $0.pexelsAPIClient.searchPhotos = { _ in
                throw TestError(message: "Network error")
            }
        }
        
        await store.send(.loadMorePhotos) {
            $0.isPaging = true
            $0.currentPage = 2
        }
        
        await store.receive(\.searchResponse.failure) {
            $0.isLoading = false
            $0.isPaging = false
            $0.photos = initialPhotos
            $0.errorMessage = "エラーが発生しました。再度やり直してください"
        }
    }
    
    @Test("ページング中のページング")
    @MainActor
    func loadMorePhotosWhenAlreadyPaging() async {
        let store = TestStore(
            initialState: PexelsSearchReducer.State(
                searchQuery: "test",
                isPaging: true,
                hasMorePages: true
            )
        ) {
            PexelsSearchReducer()
        }
        
        await store.send(.loadMorePhotos)
    }
    
    @Test("ページがもうない場合のページング")
    @MainActor
    func loadMorePhotosWhenNoMorePages() async {
        let store = TestStore(
            initialState: PexelsSearchReducer.State(
                searchQuery: "test",
                hasMorePages: false
            )
        ) {
            PexelsSearchReducer()
        }
        
        await store.send(.loadMorePhotos)
    }
    
    @Test("写真のタップ")
    @MainActor
    func photoTapped() async {
        let photo = PexelsPhoto(
            id: 1,
            width: 1920,
            height: 1080,
            url: "https://example.com/photo1",
            photographer: "Test Photographer",
            photographerUrl: "https://example.com/photographer",
            photographerId: 123,
            avgColor: "#000000",
            src: PexelsPhotoSource(
                original: "https://example.com/original",
                large2x: "https://example.com/large2x",
                large: "https://example.com/large",
                medium: "https://example.com/medium",
                small: "https://example.com/small",
                portrait: "https://example.com/portrait",
                landscape: "https://example.com/landscape",
                tiny: "https://example.com/tiny"
            ),
            liked: false,
            alt: "Test photo"
        )
        
        let store = TestStore(
            initialState: PexelsSearchReducer.State()
        ) {
            PexelsSearchReducer()
        }
        
        await store.send(.photoTapped(photo)) {
            $0.selectedImageURL = URL(string: "https://example.com/large2x")
        }
    }
    
    @Test("エラークリア")
    @MainActor
    func clearError() async {
        let store = TestStore(
            initialState: PexelsSearchReducer.State(
                errorMessage: "Some error"
            )
        ) {
            PexelsSearchReducer()
        }
        
        await store.send(.clearError) {
            $0.errorMessage = nil
        }
    }
}
