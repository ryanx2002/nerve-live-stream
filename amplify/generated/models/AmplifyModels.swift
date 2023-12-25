// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "8d8bb81f0ffab3daf935849dcded627d"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: StreamView.self)
    ModelRegistry.register(modelType: Gift.self)
    ModelRegistry.register(modelType: Stream.self)
  }
}