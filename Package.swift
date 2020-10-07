// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SQLite",
    products: [
        .library(
            name: "SQLite",
            targets: ["SQLite"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SQLite",
            dependencies: ["sqlite3"],
            cSettings: [
                .define("SQLITE_ENABLE_COLUMN_METADATA"),
                .define("SQLITE_ENABLE_PREUPDATE_HOOK"),
            ]
        ),
        .target(
            name: "sqlite3",
            dependencies: [],
            cSettings: [
                .define("SQLITE_ENABLE_COLUMN_METADATA"),
                .define("SQLITE_ENABLE_PREUPDATE_HOOK"),
            ]
        ),
        .testTarget(
            name: "SQLiteTests",
            dependencies: ["SQLite"],
            resources: [
                .copy("test.sqlite"),
            ]
        ),
    ]
)
