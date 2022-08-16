// swiftlint:disable all
import Amplify
import Foundation

public struct UserDetails: Model {
  public let id: String
  public var username: String
  public var fullName: String
  public var address: String
  public var programType: String?
  public var phoneNumber: String
  
  public init(id: String = UUID().uuidString,
      username: String,
      fullName: String,
      address: String,
      programType: String? = nil,
      phoneNumber: String) {
      self.id = id
      self.username = username
      self.fullName = fullName
      self.address = address
      self.programType = programType
      self.phoneNumber = phoneNumber
  }
}