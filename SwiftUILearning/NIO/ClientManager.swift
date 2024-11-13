//
//  ClientManager.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/13.
//

import NIO
import NIOExtras
import NIOCore

class ClientManager {
    static let shared = ClientManager() // 单例实例
    private var eventLoopGroup: EventLoopGroup
    private var bootstrap: ClientBootstrap!
    private var channel: Channel?
    
    // 存储请求序列号与回调的映射
    private var requests: [Int: (String) -> Void] = [:]
    private var currentSequenceNumber: Int = 0
    
    private init(eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)) {
        self.eventLoopGroup = eventLoopGroup
        self.bootstrap = ClientBootstrap(group: eventLoopGroup)
        self.bootstrap = bootstrap.channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { [weak self] channel in
                guard let self = self else {
                    return channel.pipeline.addHandlers([])
                }
                return channel.pipeline.addHandlers([DebugInboundEventsHandler(), ClientHandler(delegate: self)])
            }
    }
    
    // 生成下一个序列号
    private func nextSequenceNumber() -> Int {
        currentSequenceNumber += 1
        return currentSequenceNumber
    }
    
    // 连接到服务器
    func connect(host: String, port: Int) {
        let promise = self.eventLoopGroup.next().makePromise(of: Void.self)
        
        bootstrap.connect(host: host, port: port).whenComplete { result in
            switch result {
            case .success(let channel):
                self.channel = channel
                promise.succeed(())
            case .failure(let error):
                promise.fail(error)
            }
        }
        
        promise.futureResult.whenComplete { _ in
            print("Client connected")
        }
    }
    
    // 发送消息并处理响应，传入的闭包会在服务器响应后被调用
    func sendMessage(_ message: String, responseHandler: @escaping (String) -> Void) {
        guard let channel = channel else {
            print("No channel available")
            return
        }
        
        // 创建包含序列号的消息
        let sequenceNumber = nextSequenceNumber()
        let messageWithSequence = "\(sequenceNumber):\(message)"
        
        // 保存回调
        requests[sequenceNumber] = responseHandler
        
        let buffer = channel.allocator.buffer(string: messageWithSequence)
        channel.writeAndFlush(buffer, promise: nil)
    }
    
    // 关闭连接
    func close() {
        guard let channel = channel else { return }
        channel.close(promise: nil)
    }
    
    // 处理从服务器接收到的响应
    func handleResponse(sequenceNumber: Int, response: String) {
        // 匹配序列号，执行对应的回调并移除映射
        if let responseHandler = requests.removeValue(forKey: sequenceNumber) {
            responseHandler(response)
        } else {
            print("Unexpected response for sequence number \(sequenceNumber)")
        }
    }
}

