//
//  GFTeemoHeartbeatHandler.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/13.
//

import NIO
import NIOCore

class GFTeemoHeartbeatHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ByteBuffer

    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        if let idleEvent = event as? IdleStateHandler.IdleStateEvent {
            switch idleEvent {
            case .all, .read, .write:
                // 处理空闲事件，触发心跳包
                print("\(context.channel.isActive)")
                sendHeartbeat(context: context)
            }
        }
        context.fireUserInboundEventTriggered(event)
    }

    private func sendHeartbeat(context: ChannelHandlerContext) {
        let hearbeat = Com_Gtjaqh_Zhuque_Ngate_SystemHeartbeatRequest()
        GFTeemoClientManager.shared.sendMessage(message: hearbeat) { heartBeatRsp in
            guard heartBeatRsp.data is Com_Gtjaqh_Zhuque_Ngate_SystemHeartbeatResponse else {
                return
            }
            print("jpf 收到心跳回复")
        }
    }
}
