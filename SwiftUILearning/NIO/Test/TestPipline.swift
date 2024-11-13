//
//  TestPipline.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/11.
//

import Foundation
import NIO
class TestPipline {
    static func testPipline() {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)  // 只使用一个线程
        let bootstrap = ClientBootstrap(group: eventLoopGroup).channelInitializer { channel in
            let handler1 = SimpleInboundHandler()
            let handler2 = SimpleInboundHandler()
            return channel.pipeline.addHandlers(handler1, handler2).map {
                // This block runs once the handlers are added successfully
                print("Handlers added to the pipeline")
            }.flatMapError { error in
                // Handle any errors that occurred while adding handlers
                print("Failed to add handlers to the channel: \(error)")
                return channel.eventLoop.makeFailedFuture(error)  // Return the failure
            }
        }
    }
}
