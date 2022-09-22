// swiftlint:disable all
import Amplify
import Foundation

public struct Outing: Model {
  public let id: String
  public var title: String
  public var description: String
  public var location: String
  public var startDate: Temporal.Date
  public var startTime: Temporal.Time
  public var endDate: Temporal.Date
  public var endTime: Temporal.Time
  public var instructors: [String]
  public var numClients: Int
  public var programType: [String]
  public var OutingsandUsers: List<OutingUserDetails>?
  
  public init(id: String = UUID().uuidString,
      title: String,
      description: String,
      location: String,
      startDate: Temporal.Date,
      startTime: Temporal.Time,
      endDate: Temporal.Date,
      endTime: Temporal.Time,
      instructors: [String] = [],
      numClients: Int,
      programType: [String] = [],
      OutingsandUsers: List<OutingUserDetails>? = []) {
      self.id = id
      self.title = title
      self.description = description
      self.location = location
      self.startDate = startDate
      self.startTime = startTime
      self.endDate = endDate
      self.endTime = endTime
      self.instructors = instructors
      self.numClients = numClients
      self.programType = programType
      self.OutingsandUsers = OutingsandUsers
  }
}