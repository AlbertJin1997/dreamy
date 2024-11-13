//
//  ClientHandler.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/13.
//

import NIO

class ClientHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = Void
    
    weak var delegate: ClientManager?
    
    init(delegate: ClientManager?) {
        self.delegate = delegate
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let buffer = self.unwrapInboundIn(data)
        
        // 假设服务器返回的响应是类似于 "序列号:响应内容" 格式
        if let response = buffer.getString(at: buffer.readerIndex, length: buffer.readableBytes) {
            let components = response.split(separator: ":")
            if components.count == 2, let sequenceNumber = Int(components[0]) {
                // 提取序列号并将响应传递给 ClientManager 处理
                delegate?.handleResponse(sequenceNumber: sequenceNumber, response: String(components[1]))
            }
        }
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error occurred: \(error)")
        context.close(promise: nil)
    }
}
