#  swift-emoji

Turn Slack-like emoji shortcuts into their Unicode representations. Based on [emoji-data].

## Installation

Add `swift-emoji` to an Xcode project by adding it as a package: https://github.com/klaaspieter/swift-emoji

Or add it to your `Package.swift`:

```swift
Package(
  // Your package metadata
  
  dependencies: [
    .package(url: "https://github.com/klaaspieter/swift-emoji", from: "1.0.0")
  ],
  
  targets: [
    .target(
      // Other target metadata
      dependencies: [
        .product(name: "Emoji", package: "swift-emoji")
      ]
    )
  ]
)
```

## Usage

Use the `EmojiData` namespace to interact with emojis in different ways:

```swift
import EmojiData

EmojiData.emoji(fromUnified: "261D-FE0F") // ☝️
EmojiData.emoji(fromShortName: "running") // 🏃
```


## EmojiDataSource

The [emoji-data] JSON is parsed into `Data.swift` to prevent having to load and parse the data whenever the library is used. You can access the emoji data directly by importing `EmojiDataSource`:

```
import EmojiDataSource

EmojiDataSource.emojis
```

To regenerate the data run `convert.swift` in the `Support` directory.

[emoji-data]: https://github.com/iamcal/emoji-data
