import XCTest
import EmojiData

final class emojiTests: XCTestCase {
  func testAll() {
    XCTAssertEqual(EmojiData.all.count, 1903)
  }

  func testFromUnified() {
    XCTAssertEqual(EmojiData.emoji(fromUnified: "261D-FE0F")?.character, "☝️")
    XCTAssertEqual(EmojiData.emoji(fromUnified: "1F3C3-1F3FB-200D-2640-FE0F")?.shortName, "woman-running")
  }

  func testFromShortName() {
    XCTAssertEqual(EmojiData.emoji(fromShortName: "santa")?.name, "FATHER CHRISTMAS")
    XCTAssertEqual(EmojiData.emoji(fromShortName: "running")?.character, "🏃")
  }

  func testEmojiFromCharacter() {
    // Ensure that we properly handle the Strip Variation Selector 16 (U+FE0F); which tells a preceding character to render as emoji.
    // For example ☕️ is comprised of U+2615-U+FE0F, but is just `2615` in our lookup table because
    // the variation selector doesn't do anything sicne there is no text representation for the emoji.
    // However it is required for ☃️ because it has a text representation (☃).
    XCTAssertEqual(EmojiData.emoji(fromCharacter: "\u{2615}")?.name, "HOT BEVERAGE")
    XCTAssertEqual(EmojiData.emoji(fromCharacter: "\u{2615}\u{FE0F}")?.name, "HOT BEVERAGE")
    XCTAssertEqual(EmojiData.emoji(fromCharacter: "☃️")?.name, "SNOWMAN")

    // Ensure we handle skin tone variations
    XCTAssertEqual(EmojiData.emoji(fromCharacter: "🥷")?.name, "NINJA")
    XCTAssertEqual(EmojiData.emoji(fromCharacter: "🥷🏿")?.name, "NINJA")
    XCTAssertEqual(EmojiData.emoji(fromCharacter: "🙏🏿")?.character, "🙏🏿")
    XCTAssertEqual(
      EmojiData.emoji(fromCharacter: "🙏🏿")?.skinVariations?.values.map { $0.character }.sorted(),
      ["🙏🏼", "🙏🏾", "🙏🏽", "🙏🏻"].sorted()
    )
  }

  func emoji() {
    let emoji = Emoji(
      name: "WOMAN RUNNING",
      unified: "1F3C3-200D-2640-FE0F",
      shortName: "woman-running",
      shortNames: ["woman-running"],
      skinVariations: [:]
    )
    XCTAssertEqual(emoji.character, "🏃‍♀️")
  }

  func testCharacterFromShortCode() {
    XCTAssertEqual(EmojiData.character(fromShortCode: ":grin:"), "😁")
    XCTAssertEqual(EmojiData.character(fromShortCode: ":pray::skin-tone-1:"), "🙏")
    XCTAssertEqual(EmojiData.character(fromShortCode: ":pray::skin-tone-2:"), "🙏🏻")
    XCTAssertEqual(EmojiData.character(fromShortCode: ":pray::skin-tone-3:"), "🙏🏼")
    XCTAssertEqual(EmojiData.character(fromShortCode: ":pray::skin-tone-4:"), "🙏🏽")
    XCTAssertEqual(EmojiData.character(fromShortCode: ":pray::skin-tone-5:"), "🙏🏾")
    XCTAssertEqual(EmojiData.character(fromShortCode: ":pray::skin-tone-6:"), "🙏🏿")
  }

  func testStringReplacing() {
    XCTAssertEqual(
      EmojiData.replaceShortNamesByEmojiCharacters(in: ":wave: welcome :sweat_smile:. I've got my :eyes: on you."),
      "👋 welcome 😅. I've got my 👀 on you."
    )
  }
}
