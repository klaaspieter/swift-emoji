import Foundation

private func emoji(unified: String) -> String {
  let components = unified.components(separatedBy: "-")
  let values = components.compactMap{ UInt32($0, radix: 16) }
  let unicodeScalars = values.compactMap(Unicode.Scalar.init)
  return String(String.UnicodeScalarView(unicodeScalars))
}

/// A representation of a single emoji character and its associated metadata.
public struct EmojiCharacter: Equatable, Decodable {
  public struct SkinVariation: Equatable, Decodable {
    public let unified: String

    /// The emoji character variation as a `String`
    /// For example `1F476-1F3FD` is rendered as 👶🏽
    public var character: String {
      emoji(unified: unified)
    }
  }

  /// The offical Unicode name, in SHOUTY UPPERCASE.
  public let name: String

  /// The Unicode codepoint, as 4-5 hex digits. Where an emoji needs 2 or more codepoints, they are specified like 1F1EA-1F1F8.
  /// For emoji that need to specifiy a variation selector (-FE0F), that is included here.
  public let unified: String

  /// The commonly-agreed upon short name for the image, as supported in campfire, github etc via the :colon-syntax:
  public let shortName: String

  /// An array of all the known short names.
  public let shortNames: [String]

  /// For emoji with multiple skin tone variations, a list of alternative glyphs, keyed by the skin tone.
  /// For emoji that support multiple skin tones within a single emoji, each skin tone is separated by a dash character.
  public let skinVariations: [String: SkinVariation]?

  public init(
    name: String,
    unified: String,
    shortName: String,
    shortNames: [String],
    skinVariations: [String: SkinVariation]?
  ) {
    self.name = name
    self.unified = unified
    self.shortName = shortName
    self.shortNames = shortNames
    self.skinVariations = skinVariations
  }

  /// The emoji character as a `String`
  /// /// For example `1F476` is rendered as 👶
  public var character: String {
    emoji(unified: unified)
  }
}

public struct Emoji {
  private static var decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  struct LoadError: Error {}

  private let emojis: [EmojiCharacter]
  private let emojisByUnified: [String: EmojiCharacter]
  private let emojisByShortName: [String: EmojiCharacter]
  private let emojisByCharacter: [String: EmojiCharacter]
  private let regex: NSRegularExpression

  public init() async throws {
    let task = Task {
      guard let url = Bundle.module.url(forResource: "emoji", withExtension: "json") else {
        throw LoadError()
      }
      let data = try Data(contentsOf: url)

      return try Self.decoder.decode([EmojiCharacter].self, from: data)
    }
    self.emojis = try await task.value

    var emojisByUnified: [String: EmojiCharacter] = [:]
    var emojisByShortName: [String: EmojiCharacter] = [:]
    var emojisByCharacter: [String: EmojiCharacter] = [:]
    for emoji in self.emojis {
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
    self.emojisByUnified = emojisByUnified
    self.emojisByShortName = emojisByShortName
    self.emojisByCharacter = emojisByCharacter

    let shortNames = emojisByShortName.keys.joined(separator: "|")
    let escapedShortNames = try NSRegularExpression(pattern: "[.*+?^${}()\\[\\]\\\\]")
      .stringByReplacingMatches(
        in: shortNames,
        range: NSRange(location: 0, length: shortNames.count), withTemplate: "\\$0"
      )

    self.regex = try NSRegularExpression(
      pattern: ":(\(escapedShortNames)):"
    )
  }

  /// Find an ``EmojiCharacter`` by unified codepoint ID.
  ///
  /// - Parameters:
  ///   - unified: The unified codepoint ID for an emoji.
  ///
  /// - Returns The ``EmojiCharacter`` or `nil` when there is no Emoji for the given codepoint ID
  public func from(unified: String) -> EmojiCharacter? {
    self.emojisByUnified[unified]
  }

  /// Find an ``EmojiCharacter`` by any of it's known short names
  ///
  /// - Parameters:
  ///   - shortName: The shortname to look for
  ///
  /// Returns The ``EmojiCharacter`` or `nil` when there is no Emoji for the given short name
  public func from(shortName: String) -> EmojiCharacter? {
    self.emojisByShortName[shortName]
  }

  public func from(character: String) -> EmojiCharacter? {
    self.emojisByCharacter[character]
  }

  public func replaceShortNamesByEmojiCharacters(in string: String) -> String {
    let nsString = NSMutableString(string: string)

    let matches = regex.matches(in: string, range: NSRange(location: 0, length: string.count))
    for match in matches.reversed() {
      let emojiShortName = nsString.substring(with: match.range(at: 1))

      nsString.replaceCharacters(in: match.range, with: emojisByShortName[emojiShortName]?.character ?? "")
    }

    return nsString as String
  }
}
