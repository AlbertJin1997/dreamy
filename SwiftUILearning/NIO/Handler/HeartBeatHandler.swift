//
//  HeartBeatHandler.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/13.
//

import NIO
import NIOCore

class HeartbeatHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ByteBuffer
    
    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        if let idleEvent = event as? IdleStateHandler.IdleStateEvent {
            switch idleEvent {
            case .all:
                // 如果读取和写入都为空闲（例如没有任何通信），发送心跳包
                sendHeartbeat(context: context)
            case .read:
                // 如果读取空闲，触发心跳
                sendHeartbeat(context: context)
            case .write:
                // 如果写入空闲，触发心跳
                sendHeartbeat(context: context)
            }
        }
    }
    
    private func sendHeartbeat(context: ChannelHandlerContext) {
        context.channel.writeAndFlush(ByteBuffer(string: "heartBeat")).whenSuccess { _ in
            print("Sent heartbeat success")
        }
    }
}

