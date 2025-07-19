import SwiftUI
import Combine

/// A protocol that defines the core requirements for a TinyTCA feature
/// All associated types must be Sendable for Swift 6 concurrency compliance
protocol Feature: Sendable {
    associatedtype State: Sendable
    associatedtype Action: Sendable

    /// The initial state of the feature
    static var initialState: State { get }

    /// The reducer function that handles state mutations (sync)
    static func reducer(state: inout State, action: Action) throws

    /// Optional async effect for side effects. Return an Action? to be dispatched after the effect completes.
    static func effect(for action: Action, state: State) async throws -> Action?
}

extension Feature {
    // Default implementation: no effect
    static func effect(for action: Action, state: State) async throws -> Action? { nil }
}

/// A store that manages state and handles actions for a specific feature
/// Marked as @MainActor to ensure all state mutations happen on the main actor
@MainActor
final class Store<F: Feature>: ObservableObject {
    @Published private(set) var state: F.State

    init() {
        self.state = F.initialState
    }

    /// Send an action to the store (sync, triggers effect if present)
    func send(_ action: F.Action) {
        try? F.reducer(state: &state, action: action)
        Task {
            if let followUp = try? await F.effect(for: action, state: state) {
                self.send(followUp)
            }
        }
    }

    /// A two-way binding to the store's state for SwiftUI
    var binding: Binding<F.State> {
        Binding(
            get: { self.state },
            set: { self.state = $0 }
        )
    }

    /// Helper for SwiftUI previews
    static func preview(_ state: F.State) -> Store<F> {
        let store = Store<F>()
        store.state = state
        return store
    }
}

/// A property wrapper that provides access to the store's state
/// Must be used from MainActor context due to Store being @MainActor
@propertyWrapper @MainActor
struct StoreState<F: Feature>: DynamicProperty {
    @ObservedObject private var store: Store<F>

    public init(_ store: Store<F>) {
        self.store = store
    }

    public var wrappedValue: F.State {
        store.state
    }

    public var projectedValue: Store<F> {
        store
    }
}
