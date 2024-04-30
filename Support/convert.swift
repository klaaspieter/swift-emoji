#!/usr/bin/env swift

import Foundation

private func emoji(unified: String) -> String {
  let components = unified.components(separatedBy: "-")
  let values = components.compactMap{ UInt32($0, radix: 16) }
  let unicodeScalars = values.compactMap(Unicode.Scalar.init)
  return String(String.UnicodeScalarView(unicodeScalars))
}

public struct Emoji: Equatable, Decodable {
  public struct SkinVariation: Equatable, Decodable {
    public let unified: String

    public init(unified: String) {
      self.unified = unified
    }

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
  /// For example `1F476` is rendered as 👶
  public var character: String {
    emoji(unified: unified)
  }
}

func string(for variation: Emoji.SkinVariation) -> String {
  "Emoji.SkinVariation(unified: \"\(variation.unified)\")"
}

func string(for emoji: Emoji) -> String {
  let shortNames = emoji.shortNames.map { "\"\($0)\"" }.joined(separator: ",")

  let skinVariations: String
  if let variations = emoji.skinVariations {
    var result: [String] = []
    for (key, variation) in variations {
      result.append("\"\(key)\": \(string(for: variation))")
    }
    skinVariations = "[\(result.joined(separator: ","))]"

  } else {
    skinVariations = "nil"
  }

  return "Emoji(name: \"\(emoji.name)\", unified: \"\(emoji.unified)\", shortName: \"\(emoji.shortName)\", shortNames: [\(shortNames)], skinVariations: \(skinVariations))"
}

private var decoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  return decoder
}()

let url = URL(fileURLWithPath: "./emoji.json")
let data = try! Data(contentsOf: url)

let emojis = try! decoder.decode([Emoji].self, from: data)

var output = """
public let emojis: [Emoji] = {
  var emojis: [Emoji] = []

"""

for emoji in emojis {
  output += "  emojis.append(\(string(for: emoji)))\n"
}

output += """
  return emojis
}()
"""
let writeURL = URL(fileURLWithPath: "./../Sources/EmojiDataSource/Data.swift")
try! output.write(to: writeURL, atomically: true, encoding: .utf8)
