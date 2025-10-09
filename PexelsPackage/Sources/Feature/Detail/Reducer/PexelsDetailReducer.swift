//
//  PexelsDetailReducer.swift
//  PexelsPackage
//
//  Created by air2 on 2025/10/09.
//

import ComposableArchitecture
import Foundation
import PexelsModuleData

@Reducer
public struct PexelsDetailReducer: Sendable {
    @ObservableState
    public struct State: Equatable {
        let photo: PexelsPhoto

        public init(photo: PexelsPhoto) {
            self.photo = photo
        }
    }

    public enum Action {
        case closeButtonTapped
    }

    public init() {}

    @Dependency(\.dismiss) var dismiss

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .closeButtonTapped:
                .run { _ in await dismiss() }
            }
        }
    }
}
