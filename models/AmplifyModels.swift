// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "515f850457c9bdc578ac6202fe5bdac0"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Outing.self)
    ModelRegistry.register(modelType: OutingUserDetails.self)
    ModelRegistry.register(modelType: UserDetails.self)
  }
}