// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-emoji",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_13),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "EmojiData",
      targets: ["EmojiData"]
    ),
    .library(
      name: "EmojiDataSource",
      targets: ["EmojiDataSource"]
    ),
  ],
  targets: [
    .target(
      name: "EmojiData",
      dependencies: [.targetItem(name: "EmojiDataSource", condition: nil)]
    ),
    .target(
      name: "EmojiDataSource"
    ),
    .testTarget(
      name: "EmojiTests",
      dependencies: ["EmojiData"]
    ),
  ]
)
