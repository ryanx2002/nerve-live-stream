// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "d8c1a27488741b3044f84ce9500c52f7"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: StreamView.self)
    ModelRegistry.register(modelType: Gift.self)
    ModelRegistry.register(modelType: Stream.self)
  }
}