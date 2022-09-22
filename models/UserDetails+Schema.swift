// swiftlint:disable all
import Amplify
import Foundation

extension UserDetails {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case username
    case fullName
    case address
    case programType
    case phoneNumber
    case userType
    case outings
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let userDetails = UserDetails.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "UserDetails"
    
    model.fields(
      .id(),
      .field(userDetails.username, is: .required, ofType: .string),
      .field(userDetails.fullName, is: .required, ofType: .string),
      .field(userDetails.address, is: .required, ofType: .string),
      .field(userDetails.programType, is: .required, ofType: .embeddedCollection(of: String.self)),
      .field(userDetails.phoneNumber, is: .required, ofType: .string),
      .field(userDetails.userType, is: .optional, ofType: .enum(type: UserGroup.self)),
      .hasMany(userDetails.outings, is: .optional, ofType: OutingUserDetails.self, associatedWith: OutingUserDetails.keys.userdetails)
    )
    }
}