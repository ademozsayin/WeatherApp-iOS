// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FiableAuthenticator", // Name of your package
    platforms: [
        .iOS(.v15) // Set the minimum iOS version to 15.0
    ],
    products: [
        // Define the products your package produces, in this case, a library named "FiableAuthenticator"
        .library(
            name: "FiableAuthenticator",
            targets: ["FiableAuthenticator"]),
    ],
    dependencies: [
        // Specify local package dependencies using the .package(path:) method
        .package(path: "FiableUI"), // Local package named "FiableUI"
        .package(path: "FiableShared"), // Local package named "FiableShared"
        .package(path: "FiableKit"), // Local package named "FiableKit"
        .package(url: "https://github.com/SVProgressHUD/SVProgressHUD.git", from: "2.2.5"), // SVProgressHUD package from GitHub
    ],
    targets: [
        // Define the targets in your package, such as the main target and test target
        .target(
            name: "FiableAuthenticator",
            dependencies: ["FiableUI", "FiableShared", "SVProgressHUD","FiableKit"]), // Specify dependencies for the main target
        .testTarget(
            name: "FiableAuthenticatorTests",
            dependencies: ["FiableAuthenticator"]), // Specify dependencies for the test target
    ]
)