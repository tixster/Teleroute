import SwiftTelegramBot
import Foundation
import Synchronization

actor TelerouteMiddlewareRunner {
    let middlewares: [any TelerouteMiddleware]
    let update: TGUpdate
    let handler: TelerouteHandler
    private var handled = false

    init(
        middlewares: [any TelerouteMiddleware],
        update: TGUpdate,
        handler: @escaping TelerouteHandler
    ) {
        self.middlewares = middlewares
        self.update = update
        self.handler = handler
    }

    func run(context: TelerouteContext) async throws -> Bool {
        try await self.execute(index: 0, context: context)
        return self.handled
    }

    private func execute(index: Int, context: TelerouteContext) async throws {
        if index == self.middlewares.count {
            self.handled = true
            try await self.handler(self.update, context)
            return
        }
        let middleware = self.middlewares[index]
        let didCallNext = Mutex(false)
        try await middleware.handle(context) { [weak self] nextContext in
            didCallNext.withLock { $0 = true }
            guard let self else { return }
            try await self.execute(index: index + 1, context: nextContext)
        }
        if didCallNext.withLock({ $0 }) == false,
           middleware is any TelerouteConsumingMiddleware {
            self.handled = true
        }
    }
}
