// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SailingGTK",
    dependencies: [
        .package(name: "gir2swift", url: "https://github.com/rhx/gir2swift.git", .branch("main")),
        .package(name: "Gtk", url: "https://github.com/rhx/SwiftGtk.git", .branch("gtk3")),
        .package(name: "OpenCombine", url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.12.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "SailingGTK",
            dependencies: ["Gtk",
            "OpenCombine",
            .product(name: "OpenCombineFoundation", package: "OpenCombine"),
            .product(name: "OpenCombineDispatch", package: "OpenCombine")]),
        .testTarget(
            name: "SailingGTKTests",
            dependencies: ["SailingGTK"]),
    ]
)
