import Foundation

private func emoji(unified: String) -> String {
  let components = unified.components(separatedBy: "-")
  let values = components.compactMap{ UInt32($0, radix: 16) }
  let unicodeScalars = values.compactMap(Unicode.Scalar.init)
  return String(String.UnicodeScalarView(unicodeScalars))
}

/// A representation of a single emoji character and its associated metadata.
public struct Emoji: Equatable, Hashable, Decodable, Comparable {
  public struct SkinVariation: Equatable, Hashable, Decodable {
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

  /// The category group name.
  public let category: String

  /// Global sorting index for all emoji, based on Unicode CLDR ordering.
  public let sortOrder: Int

  /// For emoji with multiple skin tone variations, a list of alternative glyphs, keyed by the skin tone.
  /// For emoji that support multiple skin tones within a single emoji, each skin tone is separated by a dash character.
  public let skinVariations: [String: SkinVariation]?

  init(
    name: String,
    unified: String,
    shortName: String,
    shortNames: [String],
    category: String,
    sortOrder: Int,
    skinVariations: [String: SkinVariation]?
  ) {
    self.name = name
    self.unified = unified
    self.shortName = shortName
    self.shortNames = shortNames
    self.category = category
    self.sortOrder = sortOrder
    self.skinVariations = skinVariations
  }

  /// The emoji character as a `String`
  /// /// For example `1F476` is rendered as 👶
  public var character: String {
    emoji(unified: unified)
  }

  public static func < (lhs: Emoji, rhs: Emoji) -> Bool {
    lhs.sortOrder < rhs.sortOrder
  }
}
