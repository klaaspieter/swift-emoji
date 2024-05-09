extension Emoji {
  public enum Category: Hashable {
    case smileysAndEmotion
    case peopleAndBody
    case animalsAndNature
    case foodAndDrink
    case activities
    case travelAndPlaces
    case objects
    case symbols
    case flags

    init?(rawValue: String) {
      switch rawValue {
      case "Smileys & Emotion": self = .smileysAndEmotion
      case "People & Body": self = .peopleAndBody
      case "Animals & Nature": self = .animalsAndNature
      case "Food & Drink": self = .foodAndDrink
      case "Activities": self = .activities
      case "Travel & Places": self = .travelAndPlaces
      case "Objects": self = .objects
      case "Symbols": self = .symbols
      case "Flags": self = .flags
      default: return nil
      }
    }

    public var name: String {
      switch self {
      case .smileysAndEmotion: return "Smileys & Emotion"
      case .peopleAndBody: return "People & Body"
      case .animalsAndNature: return "Animals & Nature"
      case .foodAndDrink: return "Food & Drink"
      case .activities: return "Activities"
      case .travelAndPlaces: return "Travel & Places"
      case .objects: return "Objects"
      case .symbols: return "Symbols"
      case .flags: return "Flags"
      }
    }
  }
}
