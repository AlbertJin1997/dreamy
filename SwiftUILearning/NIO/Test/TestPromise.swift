import NIO

class TestPromise {
    static func testPromise() {
        // 1. 创建 EventLoopGroup，通常在应用启动时创建
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)  // 只使用一个线程
        
        // 2. 获取一个 EventLoop（事件循环）
        let eventLoop = eventLoopGroup.next()
        
        // 3. 创建一个 EventLoopPromise，指定返回类型
        let promise = eventLoop.makePromise(of: String.self)
        
        // 4. 模拟一个异步任务
        eventLoop.submit {
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                // 任务完成，设置 Promise 的结果
                promise.succeed("任务异步成功完成!")
            }
        }.whenFailure { error in
            promise.fail(error)
        }
        
        // 5. 等待 Promise 的结果
        promise.futureResult.whenSuccess { value in
            print("Promise 成功，结果是: \(value)")
        }
        
        promise.futureResult.whenFailure { error in
            print("Promise 失败，错误是: \(error)")
        }
        
    }
}
