// swiftlint:disable all
import Amplify
import Foundation

public enum UserGroup: String, EnumPersistable {
  case admin = "ADMIN"
  case employee = "EMPLOYEE"
  case client = "CLIENT"
}