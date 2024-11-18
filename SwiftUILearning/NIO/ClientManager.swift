//
//  ClientManager 2.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/18.
//


import NIO
import NIOExtras
import NIOCore
import SwiftProtobuf

class ClientManager {
    static let shared = ClientManager() // 单例实例
    private var eventLoopGroup: EventLoopGroup
    private var bootstrap: ClientBootstrap!
    private var channel: Channel?
    
    // 存储请求序列号与回调的映射
    private var requestHandlers: [Int: (Message) -> Void] = [:]
    var currentSequenceNumber: Int = 0
    private var host: String = ""
    private var port: Int = 0
    var isClosedByClient: Bool = false
    private var isConnecting: Bool = false // 用来控制连接的状态，防止并发重连
    
    // 使用 DispatchQueue 来保证线程安全
    private let requestQueue = DispatchQueue(label: "com.clientManager.requestsQueue", attributes: .concurrent)

    private init(eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)) {
        self.eventLoopGroup = eventLoopGroup
        self.bootstrap = ClientBootstrap(group: eventLoopGroup)
        
        self.bootstrap = bootstrap.channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { [weak self] channel in
//                let sslHandler = try! MutualTLSClientHandler.createSSLHandler(host: nil)
                let idleStateHandler = IdleStateHandler(readTimeout: TimeAmount.seconds(3), writeTimeout: TimeAmount.seconds(3), allTimeout: TimeAmount.seconds(3))
                return channel.pipeline.addHandlers([ReconnectHandler(), idleStateHandler, HeartbeatHandler(), ClientInboundHandler(delegate: self)])
            }
    }
    
    // 生成下一个序列号
    private func nextSequenceNumber() -> Int {
        // 检查 currentSequenceNumber 是否超过 UInt32 的最大值
        if currentSequenceNumber >= UInt32.max {
            currentSequenceNumber = 0 // 超过最大值时重置为 0
        } else {
            currentSequenceNumber += 1
        }
        return currentSequenceNumber
    }

    
    // 连接到服务器
    func connect(host: String, port: Int, completeBlock: ((Bool, String) -> Void)? = nil) {
        self.host = host
        self.port = port
        
        // 只有在没有正在连接时才允许发起连接请求
        guard !isConnecting else {
            completeBlock?(false, "Already connecting")
            return
        }
        
        self.isConnecting = true
        let promise = self.eventLoopGroup.next().makePromise(of: Void.self)
        
        bootstrap.connect(host: host, port: port).whenComplete { result in
            self.isConnecting = false
            switch result {
            case .success(let channel):
                self.channel = channel
                completeBlock?(true, "Connected successfully")
                promise.succeed(())
            case .failure(let error):
                let errorMessage = "Connection failed with error: \(error)"
                promise.fail(error)
                completeBlock?(false, errorMessage)  // 将错误信息返回给回调
            }
        }
        
        promise.futureResult.whenComplete { _ in
            print("Connection attempt completed.")
        }
    }
    
    // 尝试重新连接
    func reconnect(completeBlock: ((Bool, String) -> Void)? = nil) {
        // 检查是否正在连接中，避免重复连接
        guard !isConnecting else {
            completeBlock?(false, "Already connecting")
            return
        }
        
        // 调用 connect 方法进行重连
        connect(host: self.host, port: self.port, completeBlock: completeBlock)
    }
    
    // 发送消息并处理响应，传入的闭包会在服务器响应后被调用
    func sendMessage(_ message: Message, responseHandler: ((Message) -> Void)? = nil) {
        guard let channel = channel else {
            print("No channel available")
            return
        }
        
        // 创建包含序列号的消息
        let sequenceNumber = nextSequenceNumber()
        
        // 使用 JSON 编码进行消息格式化
        do {
            let requestType = String(describing: type(of: message))
            let data = try message.serializedData()
            var dataBuffer = channel.allocator.buffer(bytes: data)
            
            // 判断是否包含有效的 RequestType
            if !ClientUtil.RequestToFunIdDic.keys.contains(requestType) || (ClientUtil.RequestToFunIdDic[requestType] == nil) {
                return
            }
            
            let funcId = ClientUtil.RequestToFunIdDic[requestType]!
            var totalBuffer = PackageHeader(length: UInt32(GFTeemoHeaderLength) + UInt32(dataBuffer.readableBytes), serialNo: UInt32(ClientManager.shared.currentSequenceNumber), functionId: UInt16(funcId)).encode()
            totalBuffer.writeBuffer(&dataBuffer)
            
            // 如果提供了闭包，则保存回调
            if let responseHandler = responseHandler {
                requestQueue.async(flags: .barrier) {
                    self.requestHandlers[sequenceNumber] = responseHandler
                }
            }
            
            // 发送消息
            channel.writeAndFlush(totalBuffer, promise: nil)
            
        } catch {
            print("Failed to encode message: \(error)")
        }
    }
    
    // 关闭连接
    func close() {
        guard let channel = channel else { return }
        
        // 标记为客户端关闭
        self.isClosedByClient = true
        
        // 关闭连接并处理结果
        channel.close().whenComplete { result in
            switch result {
            case .success:
                // 关闭成功
                print("Channel successfully closed.")
            case .failure(let error):
                // 关闭失败
                self.isClosedByClient = false
                print("Failed to close channel with error: \(error)")
            }
        }
    }
    
    // 处理从服务器接收到的响应
    func handleResponse(sequenceNumber: Int, response: Message) {
        // 使用线程安全的队列来处理请求的回调
        requestQueue.async(flags: .barrier) {
            if let responseHandler = self.requestHandlers.removeValue(forKey: sequenceNumber) {
                // 执行对应的回调
                responseHandler(response)
            } else {
                print("No response handler found for sequence number: \(sequenceNumber)")
            }
        }
    }
}
