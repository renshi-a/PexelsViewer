//
//  PexelesSearchView.swift
//  PexelsPackage
//
//  Created by air2 on 2025/10/07.
//

import Charcoal
import ComposableArchitecture
import Foundation
import Kingfisher
import PexelsModuleData
import SwiftUI

public struct PexelsSearchView: View {
    @Bindable var store: StoreOf<PexelsSearchReducer> = .init(initialState: .init(), reducer: { PexelsSearchReducer() })

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: .zero) {
                content
            }
            .charcoalSpinner(
                isPresenting: $store.isLoading,
                spinnerSize: 48,
                transparentBackground: false,
                interactionPassthrough: false
            )
            .navigationTitle("写真を検索")
            .searchable(
                text: $store.searchQuery,
                prompt: Text("Search Pexels...")
            )
            .onSubmit(of: .search) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                store.send(.searchQuerySubmitted, animation: .easeInOut)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if store.photos.isEmpty, !store.isLoading {
            emptyPlaceHolder
        } else {
            photoGrid
        }
    }

    private var emptyPlaceHolder: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(charcoalColor: .surface4)

            Text("写真を検索")
                .charcoalTypography20Bold()
                .foregroundStyle(charcoalColor: .text1)

            Text("キーワードを入力して\nPexelsから写真を検索できます")
                .charcoalTypography16Regular()
                .foregroundStyle(charcoalColor: .text3)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2)
                ],
                spacing: 4
            ) {
                ForEach(store.photos) { photo in
                    PhotoCell(photo: photo)
                        .onAppear {
                            // 最後の写真が表示されたら次のページを読み込む
                            if photo.id == store.photos.last?.id {
                                store.send(.loadMorePhotos)
                            }
                        }
                }

                // ローディングインジケーター
                if store.isLoading {
                    ProgressView()
                        .gridCellColumns(2)
                        .frame(height: 100)
                }
            }
            .padding(8)
        }
    }
}

// MARK: - Photo Cell

private struct PhotoCell: View {
    let photo: PexelsPhoto

    var body: some View {
        KFImage(URL(string: photo.src.tiny))
            .placeholder {
                Rectangle()
                    .fill(Color(hex: photo.avgColor).opacity(0.6))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        ProgressView()
                    }
            }
            .onFailure { _ in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipped()
            .cornerRadius(8)
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
