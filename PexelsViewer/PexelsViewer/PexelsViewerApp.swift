//
//  PexelsViewerApp.swift
//  PexelsViewer
//
//  Created by air2 on 2025/10/07.
//

import ComposableArchitecture
import PexelsModuleData
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptons: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "PEXELS_API_KEY") as? String else {
            return true
        }

        @Dependency(\.pexelsAPIClient) var apiClient
        apiClient.initialize(apiKey)
        return true
    }
}

@main
struct PexelsViewerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
