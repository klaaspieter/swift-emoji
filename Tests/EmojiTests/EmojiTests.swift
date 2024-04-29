import XCTest
import Data
import Emoji

final class emojiTests: XCTestCase {
  func testFromUnified() {
    XCTAssertEqual(Emoji.from(unified: "261D-FE0F")?.character, "☝️")
    XCTAssertEqual(Emoji.from(unified: "1F3C3-1F3FB-200D-2640-FE0F")?.shortName, "woman-running")
  }

  func testFromShortName() {
    XCTAssertEqual(Emoji.from(shortName: "santa")?.name, "FATHER CHRISTMAS")
    XCTAssertEqual(Emoji.from(shortName: "running")?.character, "🏃")
  }

  func testEmojiFromCharacter() {
    XCTAssertEqual(Emoji.from(character: "🥷")?.name, "NINJA")
    XCTAssertEqual(Emoji.from(character: "🥷🏿")?.name, "NINJA")
  }

  func testCharacter() {
    let emojiCharacter = EmojiCharacter(
      name: "WOMAN RUNNING",
      unified: "1F3C3-200D-2640-FE0F",
      shortName: "woman-running",
      shortNames: ["woman-running"],
      skinVariations: [:]
    )
    XCTAssertEqual(emojiCharacter.character, "🏃‍♀️")
  }

  func testCharacterFromShortCode() {
    XCTAssertEqual(Emoji.character(fromShortCode: ":grin:"), "😁")
    XCTAssertEqual(Emoji.character(fromShortCode: ":pray::skin-tone-1:"), "🙏")
    XCTAssertEqual(Emoji.character(fromShortCode: ":pray::skin-tone-2:"), "🙏🏻")
    XCTAssertEqual(Emoji.character(fromShortCode: ":pray::skin-tone-3:"), "🙏🏼")
    XCTAssertEqual(Emoji.character(fromShortCode: ":pray::skin-tone-4:"), "🙏🏽")
    XCTAssertEqual(Emoji.character(fromShortCode: ":pray::skin-tone-5:"), "🙏🏾")
    XCTAssertEqual(Emoji.character(fromShortCode: ":pray::skin-tone-6:"), "🙏🏿")
  }

  func testStringReplacing() {
    XCTAssertEqual(
      Emoji.replaceShortNamesByEmojiCharacters(in: ":wave: welcome :sweat_smile:. I've got my :eyes: on you."),
      "👋 welcome 😅. I've got my 👀 on you."
    )
  }
}
