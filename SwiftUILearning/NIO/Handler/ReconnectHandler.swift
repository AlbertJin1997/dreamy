//
//  ReconnectHandler.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/14.
//

import NIO


/// 断线重连相关处理
///
class ReconnectHandler: ChannelInboundHandler {
    typealias InboundIn = Any
    typealias OutboundOut = Any
    
    private var reconnectAttempts = 0
    private let reconnectDelay: TimeAmount = .seconds(5)  // 重连间隔 5 秒
    

    // 处理连接断开事件
    func channelInactive(context: ChannelHandlerContext) {
        print("Connection lost, attempting to reconnect...")
        if (ClientManager.shared.isClosedByClient == true) {
            print("closed by client no need to reconnect")
            return
        }

        // 达到最大重连次数
        if reconnectAttempts < GFTeemoSocketRetryCount {
            reconnectAttempts += 1
            let delay = reconnectDelay
            context.channel.eventLoop.scheduleTask(in: delay) { [weak self] in
                // 防止在 self 被销毁后再进行重连尝试
                self?.reconnect(ctx: context)
            }
        } else {
            print("Max reconnect attempts reached, giving up.")
        }
        context.fireChannelInactive()
    }

    private func reconnect(ctx: ChannelHandlerContext) {
        ClientManager.shared.reconnect(completeBlock: { [weak self] success, errMsg in
            guard let self = self else { return }
            if success {
                print("Reconnected to server.")
                // 重置重连次数
                self.reconnectAttempts = 0
            } else {
                print("Reconnect failed. reason:\(errMsg)")
                // 失败后继续尝试
                if self.reconnectAttempts < GFTeemoSocketRetryCount {
                    self.channelInactive(context: ctx)  // 继续尝试重连
                } else {
                    print("Max reconnect attempts reached, giving up.")
                }
            }
        })
    }
}

