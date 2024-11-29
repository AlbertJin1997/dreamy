//
//  GFTeemoPackageHeader.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/15.
//

import NIO

// 定义PacketHeader结构体
struct GFTeemoPackageHeader {
    var length: UInt32
    var serialNo: UInt32
    var functionId: UInt16
    var version: UInt8
    var reserved: UInt8

    // 默认构造函数
    init(length: UInt32 = 0, serialNo: UInt32 = 0, functionId: UInt16 = 0, version: UInt8 = 100, reserved: UInt8 = 0) {
        self.length = UInt32(length)
        self.serialNo = UInt32(serialNo)
        self.functionId = UInt16(functionId)
        self.version = UInt8(version)
        self.reserved = UInt8(reserved)
    }

    // 将PacketHeader编码为ByteBuffer
    func encode() -> ByteBuffer {
        var buffer = ByteBufferAllocator().buffer(capacity: 12) // 定义一个12字节的缓冲区
        
        // 写入各个字段
        buffer.writeInteger(self.length)
        buffer.writeInteger(self.serialNo)
        buffer.writeInteger(self.functionId)
        buffer.writeInteger(self.version)
        buffer.writeInteger(self.reserved)
        
        return buffer
    }

    // 从ByteBuffer解码出PacketHeader
    static func decode(from buffer: inout ByteBuffer) -> GFTeemoPackageHeader? {
        guard let length = buffer.readInteger(as: UInt32.self),
              let serialNo = buffer.readInteger(as: UInt32.self),
              let functionId = buffer.readInteger(as: UInt16.self),
              let version = buffer.readInteger(as: UInt8.self),
              let reserved = buffer.readInteger(as: UInt8.self) else {
                  return nil
              }
        
        return GFTeemoPackageHeader(length: length, serialNo: serialNo, functionId: functionId, version: version, reserved: reserved)
    }
}
