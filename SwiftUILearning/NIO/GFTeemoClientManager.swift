//
//  ClientManager 2.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/18.
//

import NIO
import NIOCore
import NIOExtras
import SwiftProtobuf
import UIKit

class GFTeemoClientManager: GFTeemoResponseHandlerDelegate {
    static let shared = GFTeemoClientManager()  // 单例实例
    private var eventLoopGroup: EventLoopGroup
    private var bootstrap: ClientBootstrap!
    private var channel: Channel?
    private var isConnecting: Bool = false  // 用来控制连接的状态，防止并发重连
    private var responseHandlers: [Int: GFTeemoRequestModel] = [:] // 存储请求序列号与回调的映射
    private var host: String = ""
    private var port: Int = 0
    var isClosedByClient: Bool = false
    var currentSequenceNumber: Int = 0
    var hasRegistered: Bool = false

    // 使用 Dispa      tchQueue 来保证线程安全
    private let requestQueue = DispatchQueue(
        label: "com.clientManager.requestsQueue", attributes: .concurrent)

    
    /// 初始化
    /// - Parameter eventLoopGroup: eventLoopGroup description
    private init(eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)) {
        self.eventLoopGroup = eventLoopGroup
        self.bootstrap = ClientBootstrap(group: eventLoopGroup)
            .channelOption(ChannelOptions.socketOption(.tcp_nodelay), value: 1)
            .channelOption(ChannelOptions.socketOption(.so_keepalive), value: 1)
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { [weak self] channel in
                // let sslHandler = try! MutualTLSClientHandler.createSSLHandler(host: nil)
                let idleStateHandler = IdleStateHandler(
                    allTimeout: TimeAmount.seconds(Int64(GFTeemoIdleStandardInterval * 4)))
                return channel.pipeline.addHandlers([
                    // GFTeemoReconnectHandler(),
                    idleStateHandler,
                     GFTeemoHeartbeatHandler(),
                    // GFTeemoClientInboundHandler(delegate: self!),
                    MyChannelHandler(),
                    DebugInboundEventsHandler()
                ])
            }
    }


    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 生成下一个序列号
    private func nextSequenceNumber() -> Int {
        // 检查 currentSequenceNumber 是否超过 UInt32 的最大值
        if currentSequenceNumber >= UInt32.max {
            currentSequenceNumber = 0  // 超过最大值时重置为 0
        } else {
            currentSequenceNumber += 1
        }
        return currentSequenceNumber
    }

    /// 连接到服务器
    func connect(host: String, port: Int, completeBlock: ((_ success: Bool,_ errorMsg: String) -> Void)? = nil) {
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
                print("Connected successfully")
                promise.succeed(())
            case .failure(let error):
                let errorMessage = "Connection failed with error: \(error)"
                promise.fail(error)
                completeBlock?(false, errorMessage)  // 将错误信息返回给回调
                print("Connected failed")
            }
        }

        promise.futureResult.whenComplete { _ in
            print("Connection attempt completed.")
        }
        
        channel?.closeFuture.whenComplete({ _ in
            print("close")
        })
    }

    /// 尝试重新连接
    func reconnect(completeBlock: ((Bool, String) -> Void)? = nil) {
        // 检查是否正在连接中，避免重复连接
        guard !isConnecting else {
            completeBlock?(false, "Already connecting")
            return
        }

        // 调用 connect 方法进行重连
        connect(host: self.host, port: self.port, completeBlock: completeBlock)
    }

    /// 发送消息并处理响应，传入的闭包会在服务器响应后被调用
    /// - Parameters:
    ///   - message: pb对应的消息类型
    ///   - timeOut: 请求超时时间 若未设置默认为10s
    ///   - responseHandler: 返回闭包
    func sendMessage(
        message: Message, timeOut: Double = GFTeemoRequestDefaultTimeout,
        responseHandler: ((GFTeemoResponseModel) -> Void)? = nil
    ) {
        guard let channel = channel else {
            print("No channel available")
            return
        }
        // 创建包含序列号的消息
        let sequenceNumber = nextSequenceNumber()
        do {
            let requestType = String(describing: type(of: message))
            let data = try message.serializedData()
            var dataBuffer = channel.allocator.buffer(bytes: data)

            // 判断是否包含有效的 RequestType
            if !GFTeemoClientUtils.RequestToFunIdDic.keys.contains(requestType)
                || (GFTeemoClientUtils.RequestToFunIdDic[requestType] == nil)
            {
                return
            }

            let funcId = GFTeemoClientUtils.RequestToFunIdDic[requestType]!
            var totalBuffer = GFTeemoPackageHeader(
                length: UInt32(GFTeemoHeaderLength)
                    + UInt32(dataBuffer.readableBytes),
                serialNo: UInt32(GFTeemoClientManager.shared.currentSequenceNumber),
                functionId: UInt16(funcId)
            ).encode()
            totalBuffer.writeBuffer(&dataBuffer)

            requestQueue.sync {
                self.responseHandlers[sequenceNumber] = GFTeemoRequestModel(funcId: funcId, timeOut: timeOut, responseHandler: responseHandler ?? nil)
            }

            // 发送消息
            channel.writeAndFlush(totalBuffer, promise: nil)

        } catch {
            print("Failed to encode message: \(error)")
        }
    }

    /// 关闭连接
    func close() {
        guard let channel = channel else { return }

        // 标记为客户端关闭
        self.isClosedByClient = true

        // 关闭连接并处理结果
        channel.close().whenComplete { result in
            switch result {
            case .success:
                print("Channel successfully closed.")
            case .failure(let error):
                self.isClosedByClient = false
                print("Failed to close channel with error: \(error)")
            }
        }
    }

    /// 断联时释放handler字典
    func freeHandler() {
        self.requestQueue.sync {
            for (key, requestModel) in responseHandlers {
                let rsp = GFTeemoResponseModel(
                    success: false, data: Com_Gtjaqh_Zhuque_Ngate_RspInfo(),
                    errMsg: "连接断开无法执行")
                if let handler = requestModel.responseHandler {
                    handler(rsp)  // 执行闭包 告知请求方连接断开
                }
                responseHandlers.removeValue(forKey: key)  // 删除该项
            }
        }
    }
    
    
    /// 计时器轮询查找释放超时任务
    func freeTimeoutTasks() {
        self.requestQueue.sync {
            for (seq, requestModel) in self.responseHandlers {
                let curTimeStamp = Date().timeIntervalSince1970
                //若超时任务需要释放掉并返回错误
                if (curTimeStamp - requestModel.requestTimeStamp >= requestModel.timeOut) {
                    let rsp = GFTeemoResponseModel(
                        success: false, data: Com_Gtjaqh_Zhuque_Ngate_RspInfo(),
                        errMsg: "请求超时，强制释放")
                    if let handler = requestModel.responseHandler {
                        handler(rsp)  // 执行闭包 告知请求方连接断开
                    }
                    responseHandlers.removeValue(forKey: seq)  // 删除该项
                }
            }
        }
    }
    

    // MARK: GFTeemoResponseHandlerDelegate
    
    /// 处理类短连接带返回闭包的请求返回
    /// - Parameters:
    ///   - sequenceNumber: 序列号
    ///   - response: 返回闭包
    func handleResponse(sequenceNumber: Int, response: GFTeemoResponseModel) {
        // 使用线程安全的队列来处理请求的回调
        requestQueue.sync {
            if let requestModel = self.responseHandlers.removeValue(
                forKey: sequenceNumber)
            {
                // 执行对应的回调
                if let handler = requestModel.responseHandler {
                    handler(response)  // 执行闭包
                }
            } else {
                print(
                    "No response handler found for sequence number: \(sequenceNumber)"
                )
            }
        }
    }
    
    
    /// 处理服务器返回noti通知返回(无请求)
    /// - Parameters:
    ///   - sequenceNumber: 序列号
    ///   - response: 返回闭包model
    func handleNoti(sequenceNumber: Int, response: GFTeemoResponseModel) {
        guard let notiRsp = response.data as? Com_Gtjaqh_Zhuque_Ngate_NotifyReturn else {
            print("反序列化noti失效")
            return
        }
        print("=========================")
        print(notiRsp.notification.debugDescription)
    }
}


class MyChannelHandler: ChannelInboundHandler {
    typealias InboundIn = Any
    typealias InboundOut = Any

    func channelInactive(context: ChannelHandlerContext) {
        print("Channel is inactive!")
        context.fireChannelInactive()
        // 在这里处理连接断开的逻辑
    }
    
    func errorCaught(context: ChannelHandlerContext, error: any Error) {
        print("error1231")
    }
}
