import SwiftUI
import Combine

/// A protocol that defines the core requirements for a TinyTCA feature
/// All associated types must be Sendable for Swift 6 concurrency compliance
public protocol Feature: Sendable {
    associatedtype State: Sendable
    associatedtype Action: Sendable

    /// The initial state of the feature
    var initialState: State { get }

    /// The reducer function that handles state mutations (sync)
    func reducer(state: inout State, action: Action) throws

    /// Optional async effect for side effects. Return an Action? to be dispatched after the effect completes.
    func effect(for action: Action, state: State) async throws -> Action?
}

public extension Feature {
    // Default implementation: no effect
    func effect(for action: Action, state: State) async throws -> Action? { nil }
}

/// A store that manages state and handles actions for a specific feature
/// Marked as @MainActor to ensure all state mutations happen on the main actor
@MainActor
public final class Store<F: Feature>: ObservableObject {
    @Published public private(set) var state: F.State
    private let feature: F

    public init(feature: F) {
        self.feature = feature
        self.state = feature.initialState
    }

    /// Send an action to the store (sync, triggers effect if present), catch errors optionally
    public func send(_ action: F.Action, catch catchAction: ((Error) -> F.Action)? = nil) {
        try? feature.reducer(state: &state, action: action)
        Task {
            do {
                if let followUp = try await feature.effect(for: action, state: state) {
                    self.send(followUp)
                }
            } catch {
                if let catchAction {
                    self.send(catchAction(error))
                }
            }
        }
    }

    /// A two-way binding to the store's state for SwiftUI
    public var binding: Binding<F.State> {
        Binding(
            get: { self.state },
            set: { self.state = $0 }
        )
    }

    /// Helper for SwiftUI previews
    public static func preview(_ feature: F, state: F.State) -> Store<F> {
        let store = Store<F>(feature: feature)
        store.state = state
        return store
    }
}

/// A property wrapper that provides access to the store's state
/// Must be used from MainActor context due to Store being @MainActor
@propertyWrapper @MainActor
public struct StoreState<F: Feature>: DynamicProperty {
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
