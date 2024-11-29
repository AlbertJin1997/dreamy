//
//  ClientInboundHandler.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/13.
//

import NIO
import SwiftProtobuf
import Foundation

protocol GFTeemoResponseHandlerDelegate: AnyObject {
    func handleResponse(sequenceNumber: Int, response: GFTeemoResponseModel)
    func handleNoti(sequenceNumber: Int, response: GFTeemoResponseModel)
}

class GFTeemoClientInboundHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = Void
    
    weak var delegate: GFTeemoResponseHandlerDelegate?
    
    init(delegate: GFTeemoResponseHandlerDelegate) {
        self.delegate = delegate
    }
    
    func channelActive(context: ChannelHandlerContext) {
        self.getZidRequest { [weak self] (success, zid) in
            if success {
                // 处理成功的情况，比如使用 zid
                print("成功获取ZID: \(zid)")
                self?.register(withZid: zid, complete: { success in
                    if (success) {
                        print("注册成功")
                        GFTeemoClientManager.shared.hasRegistered = true
                    }
                })
            } else {
                // 处理失败的情况
                print("获取ZID失败")
            }
        }
        
        
        context.channel.eventLoop.scheduleRepeatedTask(initialDelay: TimeAmount.seconds(1), delay: TimeAmount.seconds(1), { RepeatedTask in
            GFTeemoClientManager.shared.freeTimeoutTasks()
        })
        context.fireChannelActive()
    }
    
    func channelUnregistered(context: ChannelHandlerContext) {
        print("锻炼2")
    }
    
    func channelInactive(context: ChannelHandlerContext) {
        print("锻炼1")
        GFTeemoClientManager.shared.freeHandler()
        context.fireChannelInactive()
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var buffer = self.unwrapInboundIn(data)
        guard let header = extractHeader(from: &buffer) else {
            print("Failed to extract header")
            return
        }
        
        let functionId = header.functionId
        print("header content, totalLength:\(header.length), functionId:\(functionId), serialNo:\(header.serialNo)")
        
        let dataBuffer = buffer.readSlice(length: Int(header.length) - GFTeemoHeaderLength) // 剩余数据部分
        
        // 统一处理不同functionId的逻辑
        handleFunctionId(Int(functionId), dataBuffer: dataBuffer, header: header)
        context.fireChannelRead(data)
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error occurred: \(error)")
        context.fireErrorCaught(error)
        context.close(promise: nil)
    }
    
    // 提取消息头的公用方法
    private func extractHeader(from buffer: inout ByteBuffer) -> GFTeemoPackageHeader? {
        var headBuffer = buffer.readSlice(length: GFTeemoHeaderLength)
        return GFTeemoPackageHeader.decode(from: &headBuffer!)
    }
    
    // 统一处理不同 functionId 的反序列化和响应逻辑
    private func handleFunctionId(_ functionId: Int, dataBuffer: ByteBuffer?, header: GFTeemoPackageHeader) {
        guard let dataBuffer = dataBuffer else {
            print("Data buffer is nil for functionId \(functionId)")
            return
        }
        guard let response = getMessageType(withFunId: functionId) else {
            print("unsupport funcId")
            return
        }
        deserializeAndHandleModel(dataBuffer, modelType: response.self, header: header)
    }
    
    // 通用的反序列化处理方法
    private func deserializeAndHandleModel<T: Message>(_ dataBuffer: ByteBuffer, modelType: T.Type, header: GFTeemoPackageHeader) {
        do {
            let model = try T(serializedBytes: Data(dataBuffer.readableBytesView))
            if (T.self == Com_Gtjaqh_Zhuque_Ngate_NotifyReturn.self) {
                print("收到推送消息")
                self.delegate?.handleNoti(sequenceNumber: Int(header.serialNo), response: GFTeemoResponseModel(success: true, data: model, errMsg: ""))
                return
            }
            self.delegate?.handleResponse(sequenceNumber: Int(header.serialNo), response: GFTeemoResponseModel(success: true, data: model, errMsg: ""))
        } catch {
            print("Error deserializing model \(modelType): \(error)")
        }
    }
    
    // 通过funcId获取responseType
    private func getMessageType(withFunId funcId: Int) -> Message.Type? {
        if let messageType = GFTeemoClientUtils.FunIdToResponseDic[funcId] {
            return messageType
        } else {
            return nil
        }
    }
    
    
    // 获取zid
    private func getZidRequest(complete: @escaping (_ success:Bool,_ zid: String) -> Void) {
        var zidRequest = Com_Gtjaqh_Zhuque_Ngate_SystemZIDApplyRequest()
        zidRequest.clientPlatform = "iOS"
        zidRequest.clientTime = String(Int(Date().timeIntervalSince1970 * 1000))  // 毫秒时间戳
        // 发送请求并处理响应
        GFTeemoClientManager.shared.sendMessage(message: zidRequest, timeOut: 30) { response in
            if (!response.success) {
                complete(false, response.errMsg)
                return
            }
            // 确保response包含有效的数据并进行类型转换
            guard let rsp = response.data as? Com_Gtjaqh_Zhuque_Ngate_SystemZIDApplyResponse else {
                // 响应数据类型不匹配或为空，返回错误
                complete(false, "")
                return
            }
            // 打印返回的zid
            print("zid:" + rsp.zid)
            // 返回成功并将zid传递给回调
            complete(true, rsp.zid)
        }
    }
    
    // 注册设备请求
    private func register(withZid zid:String, complete: @escaping (_ success:Bool) -> Void) {
        var register = Com_Gtjaqh_Zhuque_Ngate_SystemInfoRegisterRequest()
        register.deviceID = "fasfasfasfafasfas"
        register.appVersion = "4.0.5"
        register.xOsVersion = "ios"
        register.zid = zid
        GFTeemoClientManager.shared.sendMessage(message:register, timeOut: 20) { response in
            if (!response.success) {
                complete(false)
                return
            }
            guard let rsp = response.data as? Com_Gtjaqh_Zhuque_Ngate_SystemInfoRegisterResponse else {
                return
            }
            print(rsp.rspInfo.debugDescription)
            complete(true)
        }
    }

}

