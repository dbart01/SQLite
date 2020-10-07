// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let cSettings: [CSetting] = [
    .define("SQLITE_ENABLE_COLUMN_METADATA"),
    .define("SQLITE_ENABLE_PREUPDATE_HOOK"),
    .define("SQLITE_ENABLE_FTS5"),
]

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
            cSettings: cSettings
        ),
        .target(
            name: "sqlite3",
            dependencies: [],
            cSettings: cSettings
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
