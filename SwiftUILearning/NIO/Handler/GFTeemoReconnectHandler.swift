//
//  ReconnectHandler.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/14.
//

import NIO

/// 断线重连相关处理
///
class GFTeemoReconnectHandler: ChannelInboundHandler {
    typealias InboundIn = Any
    typealias OutboundOut = Any

    private let reconnectDelay: TimeAmount = .seconds(5)  // 重连间隔 5 秒

    // 处理连接断开事件
    func channelInactive(context: ChannelHandlerContext) {
        print("Connection lost, attempting to reconnect...")
        if GFTeemoClientManager.shared.isClosedByClient == true {
            print("closed by client no need to reconnect")
            return
        }
        context.channel.eventLoop.scheduleTask(in: reconnectDelay) { [weak self] in
            // 防止在 self 被销毁后再进行重连尝试
            self?.reconnect(ctx: context)
        }
        context.fireChannelInactive()
    }

    private func reconnect(ctx: ChannelHandlerContext) {
        GFTeemoClientManager.shared.reconnect(completeBlock: {
            [weak self] success, errMsg in
            guard let self = self else { return }
            if success {
                print("Reconnected to server.")
            } else {
                print("Reconnect failed. reason:\(errMsg)")
                // 失败后继续尝试
                self.channelInactive(context: ctx)  // 继续尝试重连
            }
        })
    }
}
