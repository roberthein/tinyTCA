import Foundation
import Combine
@testable import tinyTCA

/// A test store for testing state changes and effects in isolation.
public final class TestStore<F: Feature> {
  public init(state: F.State, feature: F) {
    self.state = state
    self.feature = feature
  }
  
  public init(feature: F) {
    self.state = feature.initialState
    self.feature = feature
  }
  
  let feature: F
  public private(set) var state: F.State
  
  public func send(_ action: F.Action) {
    try? feature.reducer(state: &state, action: action)
  }
}
