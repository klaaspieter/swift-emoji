import XCTest
import EmojiData

final class emojiTests: XCTestCase {
  func testAll() {
    XCTAssertEqual(EmojiData.all.count, 1875)
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
    XCTAssertEqual(EmojiData.emoji(fromCharacter: "🥷")?.name, "NINJA")
    XCTAssertEqual(EmojiData.emoji(fromCharacter: "🥷🏿")?.name, "NINJA")
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
