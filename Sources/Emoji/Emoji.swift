import Data
import Foundation

private enum Computed {
  static var isComputed: Bool = false
  static var emojisByUnified: [String: EmojiCharacter] = [:]
  static var emojisByShortName: [String: EmojiCharacter] = [:]
  static var emojisByCharacter: [String: EmojiCharacter] = [:]
  static var regex: NSRegularExpression = .init()
}

public enum Emoji {
  private static func prepareIfNecessary() {
    guard !Computed.isComputed else { return }
    var emojisByUnified: [String: EmojiCharacter] = [:]
    var emojisByShortName: [String: EmojiCharacter] = [:]
    var emojisByCharacter: [String: EmojiCharacter] = [:]
    for emoji in Data.emojis {
      emojisByUnified[emoji.unified] = emoji
      emojisByShortName[emoji.shortName] = emoji
      emojisByCharacter[emoji.character] = emoji

      if let variations = emoji.skinVariations {
        for (_, variation) in variations {
          emojisByUnified[variation.unified] = emoji
          emojisByCharacter[variation.character] = emoji
        }
      }

      for shortName in emoji.shortNames {
        emojisByShortName[shortName] = emoji
      }
    }
    Computed.emojisByUnified = emojisByUnified
    Computed.emojisByShortName = emojisByShortName
    Computed.emojisByCharacter = emojisByCharacter

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

  /// Find an ``EmojiCharacter`` by unified codepoint ID.
  ///
  /// - Parameters:
  ///   - unified: The unified codepoint ID for an emoji.
  ///
  /// - Returns The ``EmojiCharacter`` or `nil` when there is no Emoji for the given codepoint ID
  public static func from(unified: String) -> EmojiCharacter? {
    self.prepareIfNecessary()
    return Computed.emojisByUnified[unified]
  }

  /// Find an ``EmojiCharacter`` by any of it's known short names
  ///
  /// - Parameters:
  ///   - shortName: The shortname to look for
  ///
  /// Returns The ``EmojiCharacter`` or `nil` when there is no Emoji for the given short name
  public static func from(shortName: String) -> EmojiCharacter? {
    self.prepareIfNecessary()
    return Computed.emojisByShortName[shortName]
  }

  /// Find an ``EmojiCharacter`` by the unicode character itself
  ///
  /// - Parameters:
  ///   - character: A unicode character string like: 😀
  ///
  /// Returns The ``EmojiCharacter`` or `nil` when there is no Emoji for the given character
  public static func from(character: String) -> EmojiCharacter? {
    self.prepareIfNecessary()
    return Computed.emojisByCharacter[character]
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
    guard let emoji = from(shortName: emojiAlias) else {
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
