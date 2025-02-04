#  swift-emoji

Turn Slack-like emoji shortcuts into their Unicode representations. Based on [emoji-data].

## Installation

Add `swift-emoji` to an Xcode project by adding it as a package: https://github.com/klaaspieter/swift-emoji

Or add it to your `Package.swift`:

```swift
Package(
  // Your package metadata

  dependencies: [
    .package(url: "https://github.com/klaaspieter/swift-emoji", from: "0.1.0")
  ],

  targets: [
    .target(
      // Other target metadata
      dependencies: [
        .product(name: "EmojiData", package: "swift-emoji")
      ]
    )
  ]
)
```

## Usage

Use the `EmojiData` namespace to interact with emojis in different ways:

```swift
import EmojiData

XCTAssertEqual(EmojiData.emoji(fromUnified: "261D-FE0F")?.character, "☝️")
XCTAssertEqual(EmojiData.emoji(fromShortName: "running")?.character, "🏃")
XCTAssertEqual(EmojiData.emoji(fromCharacter: "🥷")?.shortName, "ninja")

// Slack-like short code support
XCTAssertEqual(EmojiData.character(fromShortCode: ":pray::skin-tone-6:"), "🙏🏿")

XCTAssertEqual(
  EmojiData.replaceShortNamesByEmojiCharacters(in: ":wave: welcome :sweat_smile:. I've got my :eyes: on you."),
  "👋 welcome 😅. I've got my 👀 on you."
)

// all emojis
XCTAssertEqual(EmojiData.all.count, 1903)
```

## Update Emojis

Download the latest [`emoji.json`](https://raw.githubusercontent.com/iamcal/emoji-data/master/emoji.json) and place in [Sources/EmojiData/Resources](./Sources/EmojiData/Resources/).

[emoji-data]: https://github.com/iamcal/emoji-data
