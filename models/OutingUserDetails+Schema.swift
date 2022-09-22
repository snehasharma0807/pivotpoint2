// swiftlint:disable all
import Amplify
import Foundation

extension OutingUserDetails {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case outing
    case userdetails
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let outingUserDetails = OutingUserDetails.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "OutingUserDetails"
    
    model.fields(
      .id(),
      .belongsTo(outingUserDetails.outing, is: .required, ofType: Outing.self, targetName: "outingID"),
      .belongsTo(outingUserDetails.userdetails, is: .required, ofType: UserDetails.self, targetName: "userdetailsID")
    )
    }
}