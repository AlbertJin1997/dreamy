//
//  MyProtocolDecoder.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/13.
//

import Foundation
import NIO

// 假设这是我们定义的自定义消息
struct MyMessage {
    var length: Int32
    var body: ByteBuffer
}

func createByteBuffer(from msg: MyMessage) -> ByteBuffer {
    var message = msg
    
    // 计算总字节数：长度（4字节）+ body的字节数
    let totalLength = 4 + message.body.readableBytes
    
    // 使用 ByteBufferAllocator 创建一个 ByteBuffer
    var buffer = ByteBufferAllocator().buffer(capacity: totalLength)
    
    // 将消息的 length（4字节）写入 buffer
    buffer.writeInteger(message.length)
    
    // 将 body 的内容写入 buffer
    buffer.writeBuffer(&message.body)
    
    return buffer
}

class MyProtocolDecoder: ByteToMessageDecoder {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ByteBuffer
    
    private var messageLength: Int32?
    
    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) -> DecodingState {
        // 如果没有长度值，先读取长度
        if messageLength == nil {
            guard buffer.readableBytes >= 4 else {
                // 如果没有足够的数据来读取长度字段，返回等待更多数据
                return .needMoreData
            }
            
            // 读取消息长度
            guard let length = buffer.readInteger(as: Int32.self), length >= 0 else {
                // 如果长度无效，重置状态，返回等待更多数据
                messageLength = nil
                return .needMoreData
            }
            
            // 记录消息体的长度
            messageLength = length
        }
        
        // 如果已经获取到消息长度，检查是否有足够的数据来读取消息体
        if let length = messageLength {
            guard buffer.readableBytes >= length else {
                // 如果没有足够的数据来读取消息体，返回等待更多数据
                return .needMoreData
            }
            
            // 读取消息体
            if let body = buffer.readSlice(length: Int(length)) {
                // 将解码后的消息传递到下一个处理器
                context.fireChannelRead(self.wrapInboundOut(body))
                
                // 如果成功解码一个消息，可以继续处理后续消息
                messageLength = nil // 重置状态，准备接收下一个消息
                return .continue
            } else {
                // 如果无法读取完整的消息体，返回等待更多数据
                return .needMoreData
            }
        }
        
        return .needMoreData
    }
}


