// swiftlint:disable all
import Amplify
import Foundation

public enum MesKind: String, EnumPersistable {
  case text = "TEXT"
  case attributedtext = "ATTRIBUTEDTEXT"
  case photo = "PHOTO"
  case video = "VIDEO"
  case location = "LOCATION"
  case emoji = "EMOJI"
  case audio = "AUDIO"
  case contact = "CONTACT"
  case linkpreview = "LINKPREVIEW"
  case custom = "CUSTOM"
}