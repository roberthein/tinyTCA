@testable import tinyTCA
import tinyTCATestUtils
import Testing

@Suite("Counter Feature Tests")
struct CounterFeatureTests {
  @Test("Counter increments and decrements correctly")
  func testCounter() async throws {
    let testStore = TestStore(feature: CounterFeature())
    
    testStore.send(.increment)
    #expect(testStore.state.count == 1)
    
    testStore.send(.decrement)
    #expect(testStore.state.count == 0)
    
    testStore.send(.delayedIncrement)
    #expect(testStore.state.count == 0)
  }
}

struct CounterFeature: Feature {
  struct State: Equatable {
    var count = 0
  }
  
  enum Action: Equatable {
    case increment
    case decrement
    case delayedIncrement
    case delayedIncrementResponse
  }
  
  var initialState: State { State() }
  
  func reducer(state: inout State, action: Action) throws {
    switch action {
      case .increment:
        state.count += 1
      case .decrement:
        state.count -= 1
      case .delayedIncrement:
        // No state change, the effect handles the logic
        break
      case .delayedIncrementResponse:
        state.count += 1
    }
  }
  
  // not tested yet
  func effect(for action: Action, state: State) async throws -> Action? {
    switch action {
      case .delayedIncrement:
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        return .delayedIncrementResponse
      default:
        return nil
    }
  }
}
