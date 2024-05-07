import Foundation

private enum Computed {
  static var isComputed: Bool = false
  static var allEmojis: [Emoji] = []
  static var emojisByUnified: [String: Emoji] = [:]
  static var emojisByShortName: [String: Emoji] = [:]
  static var regex: NSRegularExpression = .init()
}

public enum EmojiData {
  private static func prepareIfNecessary() {
    guard !Computed.isComputed else { return }

    let emojis: [Emoji] = {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase

      let url = Bundle.module.url(forResource: "emoji", withExtension: "json")!
      let data = try! Data(contentsOf: url)

      return try! decoder.decode([Emoji].self, from: data)
    }()

    var emojisByUnified: [String: Emoji] = [:]
    var emojisByShortName: [String: Emoji] = [:]

    for emoji in emojis {
      emojisByUnified[emoji.unified.uppercased()] = emoji
      emojisByShortName[emoji.shortName] = emoji

      if let variations = emoji.skinVariations {
        for (_, variation) in variations {
          let emojiVariation = Emoji(
            name: emoji.name,
            unified: variation.unified,
            shortName: emoji.shortName,
            shortNames: emoji.shortNames,
            skinVariations: variations.filter { $0.value != variation }
          )
          emojisByUnified[variation.unified] = emojiVariation
        }
      }

      for shortName in emoji.shortNames {
        emojisByShortName[shortName] = emoji
      }
    }
    Computed.allEmojis = emojis
    Computed.emojisByUnified = emojisByUnified
    Computed.emojisByShortName = emojisByShortName

    let shortNames = emojisByShortName.keys.joined(separator: "|")
    let escapedShortNames = try! NSRegularExpression(pattern: "[.*+?^${}()\\[\\]\\\\]")
      .stringByReplacingMatches(
        in: shortNames,
        range: NSRange(location: 0, length: shortNames.count), withTemplate: "\\$0"
      )

    Computed.regex = try! NSRegularExpression(
      pattern: ":(\(escapedShortNames)):"
    )

    Computed.isComputed = true
  }

  /// Returns all `Emoji`s
  public static var all: [Emoji] = {
    prepareIfNecessary()
    return Computed.allEmojis
  }()

  /// Find an ``Emoji`` by unified codepoint ID.
  ///
  /// - Parameters:
  ///   - unified: The unified codepoint ID for an emoji.
  ///
  /// - Returns The ``Emoji`` or `nil` when there is no Emoji for the given codepoint ID
  public static func emoji(fromUnified unified: String) -> Emoji? {
    self.prepareIfNecessary()
    return Computed.emojisByUnified[unified]
  }

  /// Find an ``Emoji`` by any of it's known short names
  ///
  /// - Parameters:
  ///   - shortName: The shortname to look for
  ///
  /// Returns The ``Emoji`` or `nil` when there is no Emoji for the given short name
  public static func emoji(fromShortName shortName: String) -> Emoji? {
    self.prepareIfNecessary()
    return Computed.emojisByShortName[shortName]
  }

  /// Find an ``Emoji`` by the unicode character itself
  ///
  /// - Parameters:
  ///   - character: A unicode character string like: 😀
  ///
  /// Returns The ``Emoji`` or `nil` when there is no Emoji for the given character
  public static func emoji(fromCharacter character: String) -> Emoji? {
    self.prepareIfNecessary()

    let scalars = character.unicodeScalars
      .map { UnicodeScalar($0) }

    var scalarsWithoutEmojiVariationSelector: [UnicodeScalar] = scalars

    // Strip Variation Selector 16 because it just tells the preceding character to render as emoji.
    // In other words U+2615 (☕️) is the same as U+2615-U+FE0F but our lookup table doesn't include the variation selector.
    // See https://symbl.cc/en/FE0F/
    if scalars.last == "\u{FE0F}".unicodeScalars.first {
      scalarsWithoutEmojiVariationSelector.removeLast()
    }

    let unified = scalars.map { String($0.value, radix: 16, uppercase: true) }.joined(separator: "-")
    let unifiedWithoutVariationSelector = scalarsWithoutEmojiVariationSelector.map { String($0.value, radix: 16, uppercase: true) }.joined(separator: "-")
    return Computed.emojisByUnified[unified] ?? Computed.emojisByUnified[unifiedWithoutVariationSelector]
  }

  /// Replace emoji short names in a string with their emoji character counterparts
  ///
  /// For example: `":grin:"` will become `"😁"`
  ///
  /// - Parameters:
  ///   - string: A string to replace short codes in
  ///
///   Returns A new string with all the known emoji short names with their emoji equivalent
  public static func replaceShortNamesByEmojiCharacters(in string: String) -> String {
    self.prepareIfNecessary()
    let nsString = NSMutableString(string: string)

    let matches = Computed.regex.matches(in: string, range: NSRange(location: 0, length: string.count))
    for match in matches.reversed() {
      let emojiShortName = nsString.substring(with: match.range(at: 1))

      nsString.replaceCharacters(in: match.range, with: Computed.emojisByShortName[emojiShortName]?.character ?? "")
    }

    return nsString as String
  }

  /// Find the emoji character for a Slack-like short code
  ///
  /// - Parameters:
  ///   - shortCode The shortcode to find the character for. Also supports skin tone short codes like `":grin::skin-tone-2:"`
  ///
  /// Returns An emoji character for the given short code or nil
  public static func character(fromShortCode shortCode: String) -> String? {
    // Simultaneously takes care of removing `:` from the string and splits skin tone from :pray::skin-tone-6:
    let emojiElements = shortCode.split(separator: ":").map(String.init)

    guard let emojiAlias = emojiElements.first else {
      return nil
    }
    guard let emoji = emoji(fromShortName: emojiAlias) else {
      return nil
    }

    if emojiElements.count < 2 {
      return emoji.character
    } else {
      let skinToneShortCode = emojiElements[1]

      let skinToneUnified: String?
      switch skinToneShortCode {
      case "skin-tone-2": skinToneUnified = "1F3FB"
      case "skin-tone-3": skinToneUnified = "1F3FC"
      case "skin-tone-4": skinToneUnified = "1F3FD"
      case "skin-tone-5": skinToneUnified = "1F3FE"
      case "skin-tone-6": skinToneUnified = "1F3FF"
      default: skinToneUnified = nil
      }

      guard let skinToneUnified, let skinVariation = emoji.skinVariations?[skinToneUnified] else {
        return emoji.character
      }

      return skinVariation.character
    }
  }
}
