// swiftlint:disable all
import Amplify
import Foundation

extension Outing {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case title
    case description
    case location
    case startDate
    case startTime
    case endDate
    case endTime
    case instructors
    case numClients
    case programType
    case OutingsandUsers
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let outing = Outing.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "Outings"
    
    model.fields(
      .id(),
      .field(outing.title, is: .required, ofType: .string),
      .field(outing.description, is: .required, ofType: .string),
      .field(outing.location, is: .required, ofType: .string),
      .field(outing.startDate, is: .required, ofType: .date),
      .field(outing.startTime, is: .required, ofType: .time),
      .field(outing.endDate, is: .required, ofType: .date),
      .field(outing.endTime, is: .required, ofType: .time),
      .field(outing.instructors, is: .required, ofType: .embeddedCollection(of: String.self)),
      .field(outing.numClients, is: .required, ofType: .int),
      .field(outing.programType, is: .required, ofType: .embeddedCollection(of: String.self)),
      .hasMany(outing.OutingsandUsers, is: .optional, ofType: OutingUserDetails.self, associatedWith: OutingUserDetails.keys.outing)
    )
    }
}