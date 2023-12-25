// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "781ccdbdbd59fe308248b342001e10c2"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: StreamView.self)
    ModelRegistry.register(modelType: Gift.self)
    ModelRegistry.register(modelType: Comment.self)
    ModelRegistry.register(modelType: Stream.self)
  }
}