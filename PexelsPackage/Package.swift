// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum PexelsModule {
    case core
    case data
    case feature

    var folderPath: String {
        switch self {
        case .core:
            "Sources/Core"
        case .data:
            "Sources/Data"
        case .feature:
            "Sources/Feature"
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
        case dynamicColor

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
            case .dynamicColor:
                .package(url: "https://github.com/yannickl/DynamicColor", from: "5.0.1")
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
        case dynamicColor

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
            case .dynamicColor:
                .product(name: "DynamicColor", package: "DynamicColor")
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
        ExternalLibrary.Package.pinRemoteImage.packageDependency,
        ExternalLibrary.Package.dynamicColor.packageDependency
    ],
    targets: [
        .target(
            name: PexelsModule.core.name,
            dependencies: [
                ExternalLibrary.Product.imageViewer.targetDependency,
                ExternalLibrary.Product.pinRemoteImage.targetDependency
            ],
            path: PexelsModule.core.folderPath,
            resources: [
                .process("Resources")
            ]
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
            name: PexelsModule.feature.name,
            dependencies: [
                ExternalLibrary.Product.swiftComposableArchitecture.targetDependency,
                ExternalLibrary.Product.kingfisher.targetDependency,
                ExternalLibrary.Product.charcoal.targetDependency,
                ExternalLibrary.Product.dynamicColor.targetDependency,
                PexelsModule.core.dependency
            ],
            path: PexelsModule.feature.folderPath
        ),
        .testTarget(
            name: "PexelsPackageTests",
            dependencies: [
                ExternalLibrary.Product.swiftComposableArchitecture.targetDependency,
                PexelsModule.data.dependency,
                PexelsModule.feature.dependency
            ]
        )
    ]
)
