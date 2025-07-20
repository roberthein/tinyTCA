<picture>
  <source srcset="SVG/tinyTCA-dark.svg" media="(prefers-color-scheme: dark)">
  <img src="SVG/tinyTCA-light.svg" alt="tinyTCA logo">
</picture>

A minimal, Swift 6 concurrency-compliant implementation of [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture) pattern for SwiftUI applications. tinyTCA provides a lightweight, type-safe approach to state management with built-in support for async effects and strict concurrency.

## Requirements

- **Swift 6.0+** with strict concurrency enabled
- **SwiftUI** framework
- **iOS 15.0+** / **macOS 12.0+** / **tvOS 15.0+** / **watchOS 8.0+**

> ⚠️ **Important**: This framework requires Swift 6 strict concurrency mode. It will not compile with earlier Swift versions or without strict concurrency enabled.

## Features

- 🎯 **Minimal API**: Just a protocol, a store, and a property wrapper
- ⚡ **Swift 6 Ready**: Full compliance with Swift 6 strict concurrency 
- 🔄 **Async Effects**: Built-in support for side effects with async/await
- 🛡️ **Type Safety**: Leverages Swift's type system for compile-time guarantees
- 🧵 **MainActor Safe**: All state mutations happen on the main actor
- 📱 **SwiftUI First**: Designed specifically for SwiftUI with `@ObservableObject` integration

## Core Concepts

### Feature Protocol

Define your app's features by conforming to the `Feature` protocol:

```swift
struct CounterFeature: Feature {
    struct State: Sendable {
        var count: Int = 0
        var isLoading: Bool = false
    }
    
    enum Action: Sendable {
        case increment
        case decrement
        case loadRandomNumber
        case setRandomNumber(Int)
    }
    
    static var initialState: State {
        State()
    }
    
    static func reducer(state: inout State, action: Action) throws {
        switch action {
        case .increment:
            state.count += 1
        case .decrement:
            state.count -= 1
        case .loadRandomNumber:
            state.isLoading = true
        case .setRandomNumber(let number):
            state.count = number
            state.isLoading = false
        }
    }
    
    static func effect(for action: Action, state: State) async throws -> Action? {
        switch action {
        case .loadRandomNumber:
            // Simulate API call
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return .setRandomNumber(Int.random(in: 1...100))
        default:
            return nil
        }
    }
}
```

### Store

The `Store` manages state and coordinates between the reducer and effects:

```swift
@MainActor
let store = Store<CounterFeature>()
```

### SwiftUI Integration

Use the `@StoreState` property wrapper to observe state changes in your SwiftUI views:

```swift
struct ContentView: View {
    @StoreState private var state: CounterFeature.State
    
    init(store: Store<CounterFeature>) {
        self._state = StoreState(store)
    }
    
    var body: some View {
        VStack {
            Text("Count: \(state.count)")
            
            if state.isLoading {
                ProgressView()
            }
            
            HStack {
                Button("Decrement") {
                    $state.send(.decrement)
                }
                
                Button("Increment") {
                    $state.send(.increment)
                }
                
                Button("Random") {
                    $state.send(.loadRandomNumber)
                }
            }
        }
    }
}
```

## Installation

### Swift Package Manager

Add tinyTCA to your project using Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/roberthein/tinyTCA`
3. Choose your version requirements

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/roberthein/tinyTCA", from: "1.0.0")
]
```

## Usage Patterns

### Simple Counter Example

```swift
struct SimpleCounterFeature: Feature {
    struct State: Sendable {
        var count: Int = 0
    }
    
    enum Action: Sendable {
        case increment
        case decrement
    }
    
    static var initialState: State { State() }
    
    static func reducer(state: inout State, action: Action) throws {
        switch action {
        case .increment: state.count += 1
        case .decrement: state.count -= 1
        }
    }
}
```

### Network Loading Example

```swift
struct UserProfileFeature: Feature {
    struct State: Sendable {
        var user: User?
        var isLoading: Bool = false
        var error: String?
    }
    
    enum Action: Sendable {
        case loadUser(id: String)
        case userLoaded(User)
        case userLoadFailed(String)
    }
    
    static var initialState: State { State() }
    
    static func reducer(state: inout State, action: Action) throws {
        switch action {
        case .loadUser:
            state.isLoading = true
            state.error = nil
        case .userLoaded(let user):
            state.user = user
            state.isLoading = false
        case .userLoadFailed(let error):
            state.error = error
            state.isLoading = false
        }
    }
    
    static func effect(for action: Action, state: State) async throws -> Action? {
        switch action {
        case .loadUser(let id):
            do {
                let user = try await UserAPI.fetchUser(id: id)
                return .userLoaded(user)
            } catch {
                return .userLoadFailed(error.localizedDescription)
            }
        default:
            return nil
        }
    }
}
```

### SwiftUI Previews

Use the `Store.preview(_:)` helper for SwiftUI previews:

```swift
#Preview {
    ContentView(store: .preview(CounterFeature.State(count: 42)))
}
```

## Architecture Guidelines

### State Design
- Keep state structs simple and focused
- All state properties must be `Sendable`
- Avoid reference types unless they conform to `Sendable`

### Action Design
- Use enum cases for all possible actions
- Include associated values for data that actions need
- Keep actions simple and focused on intent

### Reducer Rules
- Must be synchronous and deterministic
- Should only mutate state, never perform side effects
- Can throw errors for invalid state transitions

### Effect Guidelines
- Use for async operations like network calls, timers, etc.
- Always return an Action to update state with results
- Handle errors gracefully by returning appropriate failure actions

## Performance Considerations

- All state mutations occur on the main actor, ensuring UI consistency
- Effects run concurrently and don't block the main thread
- The store uses `@Published` for efficient SwiftUI updates
- Minimal overhead with no reflection or runtime magic

## Swift 6 Concurrency Compliance

tinyTCA is built from the ground up for Swift 6 strict concurrency:

- All types conform to `Sendable` where required
- State mutations are isolated to the main actor
- Effects run in async contexts safely
- No data races or concurrency warnings

## Contributing

Contributions are welcome! Please ensure all code maintains Swift 6 strict concurrency compliance and includes appropriate tests.

## Inspiration & Attribution

This framework is heavily inspired by [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture) by Point-Free. tinyTCA represents a minimal interpretation of TCA's core concepts, adapted specifically for Swift 6 strict concurrency. All credit for the original architectural patterns and concepts goes to the brilliant team at [Point-Free](https://www.pointfree.co).

## Full Disclosure
This entire framework, including its name, tagline, implementation, documentation, README, examples, and even this very disclaimer, was entirely generated by artificial intelligence. This is a demonstration of AI-assisted software development and should be thoroughly reviewed, tested, and validated before any production use.

## License

tinyTCA is available under the MIT license. See LICENSE file for more info.