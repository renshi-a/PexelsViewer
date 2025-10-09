//
//  PexelsDetailView.swift
//  PexelsPackage
//
//  Created by air2 on 2025/10/09.
//

import ComposableArchitecture
import Foundation
import PexelsModuleCore
import SwiftUI

public struct PexelsDetailView: View {
    @Bindable var store: StoreOf<PexelsDetailReducer>

    public var body: some View {
        ImageViewer(urls: [URL(string: store.photo.src.large2x)!]) {
            store.send(.closeButtonTapped)
        }
    }
}
