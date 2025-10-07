// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum PexelsModule {
    case core
    case data
    case feature
    case repository
    
    var folderPath: String {
        return switch self {
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
        return "PexelsModule" + folderPath
            .replacingOccurrences(of: "Sources", with: "")
            .replacingOccurrences(of: "/", with: "")
    }

    var dependency: Target.Dependency {
        return .byName(name: name, condition: nil)
    }
}

struct ExternalLibrary {
    enum Package {
        case swiftComposableArchitecture
        case charcoal
        case alamofire
        case kingfisher
        case imageViewer

        var packageDependency: PackageDescription.Package.Dependency {
            return switch self {
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
            }
        }
    }

    enum Product {
        case swiftComposableArchitecture
        case charcoal
        case alamofire
        case kingfisher
        case imageViewer

        var targetDependency: Target.Dependency {
            return switch self {
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
            }
        }
    }
}

let package = Package(
    name: "PexelsPackage",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PexelsPackage",
            targets: ["PexelsPackage"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PexelsPackage"),
        .testTarget(
            name: "PexelsPackageTests",
            dependencies: ["PexelsPackage"]
        ),
    ]
)
