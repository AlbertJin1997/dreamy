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
}

class ClientInboundHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = Void
    
    weak var delegate: GFTeemoResponseHandlerDelegate?
    
    init(delegate: GFTeemoResponseHandlerDelegate) {
        self.delegate = delegate
    }
    
    func channelActive(context: ChannelHandlerContext) {
        var register = Com_Gtjaqh_Zhuque_Ngate_SystemInfoRegisterRequest()
        register.deviceID = "fasfasfasfafasfas"
        register.appVersion = "4.0.5"
        register.xOsVersion = "ios"
        register.zid = "fasfasfasfafasfas"
        ClientManager.shared.sendMessage(register) { response in
            guard let rsp = response.data as? Com_Gtjaqh_Zhuque_Ngate_SystemInfoRegisterResponse else {
                return
            }
            print(rsp.rspInfo.debugDescription)
        }
        context.fireChannelActive()
    }
    
    func channelInactive(context: ChannelHandlerContext) {
        
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
    private func extractHeader(from buffer: inout ByteBuffer) -> PackageHeader? {
        var headBuffer = buffer.readSlice(length: GFTeemoHeaderLength)
        return PackageHeader.decode(from: &headBuffer!)
    }
    
    // 统一处理不同 functionId 的反序列化和响应逻辑
    private func handleFunctionId(_ functionId: Int, dataBuffer: ByteBuffer?, header: PackageHeader) {
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
    private func deserializeAndHandleModel<T: Message>(_ dataBuffer: ByteBuffer, modelType: T.Type, header: PackageHeader) {
        do {
            let model = try T(serializedBytes: Data(dataBuffer.readableBytesView))
            self.delegate?.handleResponse(sequenceNumber: Int(header.serialNo), response: GFTeemoResponseModel(success: true, data: model, errMsg: ""))
        } catch {
            print("Error deserializing model \(modelType): \(error)")
        }
    }
    
    // 通过funcId获取responseType
    private func getMessageType(withFunId funcId: Int) -> Message.Type? {
        if let messageType = ClientUtil.FunIdToResponseDic[funcId] {
            return messageType
        } else {
            return nil
        }
    }
}

