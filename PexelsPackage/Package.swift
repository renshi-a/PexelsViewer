// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum PexelsModule {
    case core
    case data
    case feature
    case repository

    var folderPath: String {
        switch self {
        case .core:
            "Sources/Core"
        case .data:
            "Sources/Data"
        case .feature:
            "Sources/Feature"
        case .repository:
            "Sources/Repository"
        }
    }

    var name: String {
        "PexelsModule" + folderPath
            .replacingOccurrences(of: "Sources", with: "")
            .replacingOccurrences(of: "/", with: "")
    }

    var dependency: Target.Dependency {
        .byName(name: name, condition: nil)
    }
}

struct ExternalLibrary {
    enum Package {
        case swiftComposableArchitecture
        case charcoal
        case alamofire
        case kingfisher
        case imageViewer
        case pinRemoteImage

        var packageDependency: PackageDescription.Package.Dependency {
            switch self {
            case .swiftComposableArchitecture:
                .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.0")
            case .charcoal:
                .package(url: "https://github.com/pixiv/charcoal-ios", .upToNextMajor(from: "2.0.0"))
            case .alamofire:
                .package(url: "https://github.com/Alamofire/Alamofire", from: "5.10.2")
            case .kingfisher:
                .package(url: "https://github.com/onevcat/Kingfisher", from: "8.1.0")
            case .imageViewer:
                .package(url: "https://github.com/Krisiacik/ImageViewer", from: "7.0.0")
            case .pinRemoteImage:
                .package(url: "https://github.com/pinterest/PINRemoteImage", from: "3.0.4")
            }
        }
    }

    enum Product {
        case swiftComposableArchitecture
        case charcoal
        case alamofire
        case kingfisher
        case imageViewer
        case pinRemoteImage

        var targetDependency: Target.Dependency {
            switch self {
            case .swiftComposableArchitecture:
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            case .charcoal:
                .product(name: "Charcoal", package: "charcoal-ios")
            case .alamofire:
                .product(name: "Alamofire", package: "Alamofire")
            case .kingfisher:
                .product(name: "Kingfisher", package: "Kingfisher")
            case .imageViewer:
                .product(name: "ImageViewer", package: "ImageViewer")
            case .pinRemoteImage:
                .product(name: "PINRemoteImage", package: "PINRemoteImage")
            }
        }
    }
}

let package = Package(
    name: "PexelsPackage",
    defaultLocalization: "ja",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "PexelsPackage",
            targets: [
                PexelsModule.core.name,
                PexelsModule.data.name,
                PexelsModule.repository.name,
                PexelsModule.feature.name
            ]
        )
    ],
    dependencies: [
        ExternalLibrary.Package.swiftComposableArchitecture.packageDependency,
        ExternalLibrary.Package.charcoal.packageDependency,
        ExternalLibrary.Package.alamofire.packageDependency,
        ExternalLibrary.Package.kingfisher.packageDependency,
        ExternalLibrary.Package.imageViewer.packageDependency,
        ExternalLibrary.Package.pinRemoteImage.packageDependency
    ],
    targets: [
        .target(
            name: PexelsModule.core.name,
            dependencies: [
                ExternalLibrary.Product.imageViewer.targetDependency,
                ExternalLibrary.Product.pinRemoteImage.targetDependency
            ],
            path: PexelsModule.core.folderPath
        ),
        .target(
            name: PexelsModule.data.name,
            dependencies: [
                ExternalLibrary.Product.swiftComposableArchitecture.targetDependency,
                ExternalLibrary.Product.alamofire.targetDependency
            ],
            path: PexelsModule.data.folderPath
        ),
        .target(
            name: PexelsModule.repository.name,
            dependencies: [
                ExternalLibrary.Product.swiftComposableArchitecture.targetDependency,
                PexelsModule.core.dependency,
                PexelsModule.data.dependency
            ],
            path: PexelsModule.repository.folderPath
        ),
        .target(
            name: PexelsModule.feature.name,
            dependencies: [
                ExternalLibrary.Product.swiftComposableArchitecture.targetDependency,
                ExternalLibrary.Product.kingfisher.targetDependency,
                ExternalLibrary.Product.charcoal.targetDependency,
                PexelsModule.core.dependency,
                PexelsModule.repository.dependency
            ],
            path: PexelsModule.feature.folderPath
        ),
        .testTarget(
            name: "PexelsPackageTests",
            dependencies: [
                ExternalLibrary.Product.swiftComposableArchitecture.targetDependency,
                PexelsModule.feature.dependency
            ]
        )
    ]
)
