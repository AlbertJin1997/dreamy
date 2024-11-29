//
//  GFTeemoDefine.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/1.
//

import Foundation

enum GFTeemoSocketDataType: UInt {
    /** 连接类型 */
    case connect = 0
    /** 业务类型 */
    case business = 1
}

enum GFTeemoSocketStatus: UInt {
    /** 初始状态 */
    case initial = 0
    /** 正在连接中 */
    case connecting = 1
    /** 连接成功 */
    case connected = 2
    /** 服务端验证通过 */
    case serverValid = 3
    /** 服务端验证失败 */
    case serverInvalid = 4
    /** SSL双向验证通过 */
    case sslValid = 5
    /** 已登录 */
    case logged = 200
}

enum GFTeemoLogoutStatus: UInt {
    /**
     已登出
     */
    case loggedOut = 5
    /**
     断联
     */
    case disconnected = 0 // 同理
}

/**  IdleHandler 创建的标准时间单位*/
let GFTeemoIdleStandardInterval = 1

/** Socket包的包头长度 */
let GFTeemoPackageHeaderLen: Int = 12

/** socket连接的服务端IP */
let GFTeemoSocketIP = "101.230.113.156"
/** socket连接的服务端Port */
let GFTeemoSocketPort = 8989
/** socket重试次数 */
let GFTeemoSocketRetryCount = 6
/** 头部固定长度*/
let GFTeemoHeaderLength = 12
/** 请求默认超时时间*/
public let GFTeemoRequestDefaultTimeout:Double = 10.0

let GFTeemoFlowNo = "flowNo"
let GFTeemoCode = "code"
let GFTeemoMsg = "msg"
let GFTeemoData = "data"

/** Package Header保留字段本地保存的Key值 */
let GFTeemoSocketPackageHeaderReservedKey = "GFTeemoSocketPackageHeaderReservedKey"
