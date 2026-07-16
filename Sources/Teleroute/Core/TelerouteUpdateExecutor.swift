import Foundation
import Synchronization

/// Runs update handlers with a fixed upper bound and suspends producers while full.
final class TelerouteUpdateExecutor: Sendable {
    private enum Slot: Sendable {
        case reserved
        case running(Task<Void, Never>, TelerouteTaskStartGate)
    }

    private struct Waiter: Sendable {
        let id: UUID
        var continuation: CheckedContinuation<UUID?, Never>?
    }

    private struct State: Sendable {
        var slots: [UUID: Slot] = [:]
        var waiters: [Waiter] = []
        var waiterHead = 0
        var cancelledWaiters: Set<UUID> = []
        var isShutdown = false
    }

    private let maximumConcurrentTasks: Int
    private let state = Mutex(State())

    init(maximumConcurrentTasks: Int) {
        precondition(
            maximumConcurrentTasks > 0,
            "maximumConcurrentUpdates must be greater than zero"
        )
        self.maximumConcurrentTasks = maximumConcurrentTasks
    }

    func submit(
        _ operation: @escaping @Sendable () async -> Void
    ) async -> Bool {
        guard let id = await self.reserve() else { return false }
        let gate = TelerouteTaskStartGate()
        let task = Task { [self] in
            guard await gate.wait() else { return }
            defer { self.finish(id: id) }
            guard Task.isCancelled == false else { return }
            await operation()
        }

        let shouldStart = self.state.withLock { state in
            guard state.isShutdown == false,
                  case .some(.reserved) = state.slots[id] else {
                return false
            }
            state.slots[id] = .running(task, gate)
            return true
        }

        guard shouldStart else {
            gate.cancel()
            task.cancel()
            return false
        }
        gate.start()
        return true
    }

    func shutdown() {
        let cancellation = self.state.withLock { state -> (
            tasks: [Task<Void, Never>],
            gates: [TelerouteTaskStartGate],
            waiters: [CheckedContinuation<UUID?, Never>]
        ) in
            guard state.isShutdown == false else { return ([], [], []) }
            state.isShutdown = true

            var tasks: [Task<Void, Never>] = []
            var gates: [TelerouteTaskStartGate] = []
            for slot in state.slots.values {
                guard case let .running(task, gate) = slot else { continue }
                tasks.append(task)
                gates.append(gate)
            }
            let waiters = state.waiters[state.waiterHead...].compactMap(\.continuation)
            state.slots.removeAll(keepingCapacity: false)
            state.waiters.removeAll(keepingCapacity: false)
            state.waiterHead = 0
            state.cancelledWaiters.removeAll(keepingCapacity: false)
            return (tasks, gates, waiters)
        }

        for gate in cancellation.gates {
            gate.cancel()
        }
        for task in cancellation.tasks {
            task.cancel()
        }
        for waiter in cancellation.waiters {
            waiter.resume(returning: nil)
        }
    }

    var isShutdown: Bool {
        self.state.withLock { $0.isShutdown }
    }

    var count: Int {
        self.state.withLock { $0.slots.count }
    }

    private func reserve() async -> UUID? {
        let waiterID = UUID()
        let reservedID = await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                self.enqueue(waiterID: waiterID, continuation: continuation)
            }
        } onCancel: {
            self.cancelWaiter(id: waiterID)
        }

        self.clearCancelledWaiter(id: waiterID)
        guard let reservedID else { return nil }
        guard Task.isCancelled == false else {
            self.releaseReservation(id: reservedID)
            return nil
        }
        return reservedID
    }

    private func enqueue(
        waiterID: UUID,
        continuation: CheckedContinuation<UUID?, Never>
    ) {
        let result = self.state.withLock { state -> UUID?? in
            if state.cancelledWaiters.remove(waiterID) != nil {
                return .some(nil)
            }
            guard state.isShutdown == false else { return .some(nil) }
            if state.slots.count < self.maximumConcurrentTasks {
                let id = UUID()
                state.slots[id] = .reserved
                return .some(id)
            }
            state.waiters.append(.init(id: waiterID, continuation: continuation))
            return nil
        }
        if let result {
            continuation.resume(returning: result)
        }
    }

    private func cancelWaiter(id: UUID) {
        let continuation = self.state.withLock { state -> CheckedContinuation<UUID?, Never>? in
            if let index = state.waiters[state.waiterHead...].firstIndex(where: { $0.id == id }) {
                let continuation = state.waiters[index].continuation
                state.waiters[index].continuation = nil
                return continuation
            }
            state.cancelledWaiters.insert(id)
            return nil
        }
        continuation?.resume(returning: nil)
    }

    private func clearCancelledWaiter(id: UUID) {
        _ = self.state.withLock {
            $0.cancelledWaiters.remove(id)
        }
    }

    private func finish(id: UUID) {
        let promoted = self.state.withLock { state -> (
            CheckedContinuation<UUID?, Never>, UUID
        )? in
            state.slots[id] = nil
            return self.promoteWaiter(in: &state)
        }
        if let (continuation, id) = promoted {
            continuation.resume(returning: id)
        }
    }

    private func releaseReservation(id: UUID) {
        let promoted = self.state.withLock { state -> (
            CheckedContinuation<UUID?, Never>, UUID
        )? in
            guard case .some(.reserved) = state.slots.removeValue(forKey: id) else {
                return nil
            }
            return self.promoteWaiter(in: &state)
        }
        if let (continuation, id) = promoted {
            continuation.resume(returning: id)
        }
    }

    private func promoteWaiter(
        in state: inout State
    ) -> (CheckedContinuation<UUID?, Never>, UUID)? {
        guard state.isShutdown == false else { return nil }
        while state.waiterHead < state.waiters.count {
            let index = state.waiterHead
            state.waiterHead += 1
            guard let continuation = state.waiters[index].continuation else {
                continue
            }
            state.waiters[index].continuation = nil
            let id = UUID()
            state.slots[id] = .reserved
            self.compactWaitersIfNeeded(in: &state)
            return (continuation, id)
        }
        self.compactWaitersIfNeeded(in: &state)
        return nil
    }

    private func compactWaitersIfNeeded(in state: inout State) {
        guard state.waiterHead >= 64, state.waiterHead * 2 >= state.waiters.count else {
            return
        }
        state.waiters.removeFirst(state.waiterHead)
        state.waiterHead = 0
    }
}

private final class TelerouteTaskStartGate: Sendable {
    private enum State: Sendable {
        case waiting(CheckedContinuation<Bool, Never>?)
        case started
        case cancelled
    }

    private let state = Mutex(State.waiting(nil))

    func wait() async -> Bool {
        if Task.isCancelled { return false }
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                let immediate = self.state.withLock { state -> Bool? in
                    switch state {
                    case .waiting:
                        state = .waiting(continuation)
                        return nil
                    case .started:
                        return true
                    case .cancelled:
                        return false
                    }
                }
                if let immediate {
                    continuation.resume(returning: immediate)
                }
            }
        } onCancel: {
            self.cancel()
        }
    }

    func start() {
        self.resolve(as: .started, result: true)
    }

    func cancel() {
        self.resolve(as: .cancelled, result: false)
    }

    private func resolve(as newState: State, result: Bool) {
        let continuation = self.state.withLock { state -> CheckedContinuation<Bool, Never>? in
            guard case let .waiting(continuation) = state else { return nil }
            state = newState
            return continuation
        }
        continuation?.resume(returning: result)
    }
}
