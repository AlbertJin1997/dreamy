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
            case .all, .read, .write:
                // 处理空闲事件，触发心跳包
                sendHeartbeat(context: context)
            }
        }
        context.fireUserInboundEventTriggered(event)
    }

    private func sendHeartbeat(context: ChannelHandlerContext) {
        let hearbeat = Com_Gtjaqh_Zhuque_Ngate_SystemHeartbeatRequest()
        ClientManager.shared.sendMessage(hearbeat) { heartBeatRsp in
            guard let rsp = heartBeatRsp as? Com_Gtjaqh_Zhuque_Ngate_SystemHeartbeatResponse else {
                return
            }
            print("jpf 收到心跳回复")
        }
    }
}
