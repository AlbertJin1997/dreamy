//
//  SimpleOutboundHandler.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/12.
//

import Foundation
import NIO

class SimpleOutboundHandler: ChannelOutboundHandler {
    // 指定你的上下文类型
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    // 处理发送的消息
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        var buffer = self.unwrapOutboundIn(data)
        // 在这里，你可以处理通过此 handler 发送的数据
        
        print("Writing data: \(buffer.readableBytes) bytes, content:\(String(describing: buffer.readString(length: buffer.readableBytes)))")
        context.write(data, promise: promise)
    }

    // 处理flush操作
    func flush(context: ChannelHandlerContext) {
        // 可以选择不做任何事情，简单地将数据刷新到通道
        context.flush()
    }
    
    
    // 处理异常
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        // 错误处理逻辑
        print("Error caught: \(error)")
        
        // 关闭通道
        context.close(promise: nil)
    }
}

