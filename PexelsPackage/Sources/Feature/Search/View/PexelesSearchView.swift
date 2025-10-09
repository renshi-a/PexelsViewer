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
import PexelsModuleCore
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
            .navigationTitle(String(localized: "SearchPhotosTitle", bundle: StringsExporter.bundle))
            .searchable(
                text: $store.searchQuery,
                prompt: Text(String(localized: "SearchPhotosTextPlaceHolder", bundle: StringsExporter.bundle))
            )
            .onSubmit(of: .search) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                store.send(.searchQuerySubmitted, animation: .easeInOut)
            }
            .fullScreenCover(item: $store.scope(state: \.pexelsDetail, action: \.pexelsDetail)) { store in
                PexelsDetailView(store: store)
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

    @ViewBuilder
    private var emptyPlaceHolder: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(charcoalColor: .surface4)

            Text(String(localized: "SearchPhotosTitle", bundle: StringsExporter.bundle))
                .charcoalTypography20Bold()
                .foregroundStyle(charcoalColor: .text1)

            Text(String(localized: "PexelSearchEmptyPlaceHolderMessage", bundle: StringsExporter.bundle))
                .charcoalTypography16Regular()
                .foregroundStyle(charcoalColor: .text3)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var photoGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)], spacing: 4) {
                ForEach(Array(store.photos.enumerated()), id: \.element.id) { index, photo in
                    PhotoCell(photo: photo)
                        .id(photo.id)
                        .task {
                            let threshold = max(0, store.photos.count - 8)
                            if index >= threshold {
                                store.send(.loadMorePhotos)
                            }
                        }
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            store.send(.photoTapped(photo))
                        }
                }
            }
            .padding(8)

            if store.isPaging {
                ProgressView()
                    .progressViewStyle(.circular)
                    .foregroundStyle(charcoalColor: .surface6)
                    .frame(height: 100)
            }
        }
    }
}

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
                            .foregroundStyle(charcoalColor: .surface4)
                    }
            }
            .resizable()
            .frame(minWidth: 0, maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            .cornerRadius(8)
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
