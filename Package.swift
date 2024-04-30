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
  ],
  targets: [
    .target(
      name: "EmojiData",
      resources: [.process("./Resources/emoji.json")]
    ),
    .testTarget(
      name: "EmojiTests",
      dependencies: ["EmojiData"]
    ),
  ]
)
