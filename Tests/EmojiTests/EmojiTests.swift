import XCTest
import Emoji

final class emojiTests: XCTestCase {
  var emoji: Emoji!

  override func setUp() async throws {
    self.emoji = try await Emoji()
  }

  func testFromUnified() {
    XCTAssertEqual(emoji.from(unified: "261D-FE0F")?.character, "☝️")
    XCTAssertEqual(emoji.from(unified: "1F3C3-1F3FB-200D-2640-FE0F")?.shortName, "woman-running")
  }

  func testFromShortName() {
    XCTAssertEqual(emoji.from(shortName: "santa")?.name, "FATHER CHRISTMAS")
    XCTAssertEqual(emoji.from(shortName: "running")?.character, "🏃")

    emoji.from(shortName: "moon")
  }

  func testEmojiFromCharacter() {
    XCTAssertEqual(emoji.from(character: "🥷")?.name, "NINJA")
    XCTAssertEqual(emoji.from(character: "🥷🏿")?.name, "NINJA")
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

  func testStringReplacing() {
    XCTAssertEqual(
      emoji.replaceShortNamesByEmojiCharacters(in: ":wave: welcome :sweat_smile:. I've got my :eyes: on you."),
      "👋 welcome 😅. I've got my 👀 on you."
    )
  }
}
