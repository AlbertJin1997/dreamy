//
//  MyProtocolEncoder.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/13.
//

import Foundation
import NIO

// 自定义的编码器
class MyProtocolEncoder: MessageToByteEncoder {
    typealias OutboundIn = MyMessage
    typealias OutboundOut = ByteBuffer
    
    func encode(data: MyMessage, out: inout ByteBuffer) throws {
        var tmpdata = data
        out.writeInteger(tmpdata.length)
        out.writeBuffer(&tmpdata.body)
    }
}
