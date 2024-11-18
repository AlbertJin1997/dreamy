//
//  SimpleInboundHandler.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/5.
//

import Foundation
import NIO
import SwiftProtobuf
import NIOCore
import NIOTLS

// 定义一个简单的 InboundHandler
class SimpleInboundHandler: ChannelInboundHandler {
    // 在这里定义输入类型（比如你收到的数据类型）
    typealias InboundIn = ByteBuffer  // 这里假设我们接收到的是 ByteBuffer 类型
    typealias InboundOut = ByteBuffer  // 如果有需要返回的数据类型，可以设置
    
    // 当接收到数据时调用此方法
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        // 从 NIOAny 中提取出实际的 ByteBuffer
        var buffer = self.unwrapInboundIn(data)
        
        print("Received data: \(String(describing: buffer.readString(length: buffer.readableBytes)))")
        // 继续将数据传递给下一个 handler
        context.fireChannelRead(data)
    }
    
    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        guard let tlsEvent = event as? TLSUserEvent else {
            context.fireUserInboundEventTriggered(event)
            return
        }
        if case .handshakeCompleted(_) = tlsEvent {
            print("jpf 握手成功")
        } else {
            context.fireUserInboundEventTriggered(event)
        }
    }
    
    // 处理错误时调用
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error caught: \(error.localizedDescription)")
        context.close(promise: nil)
    }
}
