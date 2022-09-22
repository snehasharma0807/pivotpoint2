// swiftlint:disable all
import Amplify
import Foundation

public struct OutingUserDetails: Model {
  public let id: String
  public var outing: Outing
  public var userdetails: UserDetails
  
  public init(id: String = UUID().uuidString,
      outing: Outing,
      userdetails: UserDetails) {
      self.id = id
      self.outing = outing
      self.userdetails = userdetails
  }
}