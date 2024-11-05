//
//  GFMarsDefine.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/1.
//

import Foundation

/** Socket包包头定义 */
struct GFMarsHeader {
    /** 包头+包体(4Bytes) */
    var totalLen: UInt32
    /** 包序列号(4Bytes) */
    var serialNo: UInt32
    /** 功能号(2Bytes) */
    var funcId: UInt16
    /** 版本号(1Byte） */
    var version: UInt8
    /** 预留位(1Byte) */
    var reserved: UInt8
}

enum GFMarsSocketDataType: UInt {
    /** 连接类型 */
    case connect = 0
    /** 业务类型 */
    case business = 1
}

enum GFMarsSocketStatus: UInt {
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

enum GFMarsLogoutStatus: UInt {
    /**
     已登出
     */
    case loggedOut = 5
    /**
     断联
     */
    case disconnected = 0 // 同理
}

/** 心跳间隔 */
let GFMarsHeartBeatInterval: TimeInterval = 30

/** Socket包的包头长度 */
let GFMarsPackageHeaderLen: Int = 12

// FuncId定义
struct GFMarsFuncId {
    /** 心跳 */
    static let heartBeat = 1
    /** 登录 */
    static let login = 1001
    /** 重连 */
    static let reconnect = 1002
    /** 登出 */
    static let logout = 1003
    /** 获取交易结算单 */
    static let settlementInfo = 1005
    /** 结算单确认 */
    static let settlementInfoConfirm = 1006
    /** 查持仓 */
    static let queryPosition = 2001
    /** 查委托 */
    static let queryOrder = 2033
    /** 查成交 */
    static let queryTrade = 2034
    /** 查询期权行权委托 */
    static let queryExecOrder = 2133
    /** 查询交易编码 */
    static let queryTradingCode = 3001
    /** 查询资金账户 */
    static let queryTradingAccount = 3008
    /** 查询保证金率 */
    static let instrumentMarginRate = 3044
    /** 单个合约 查询最大报单数量请求 */
    static let maxOrderVolume = 3100
    /** 交易委托下单 */
    static let orderInsert = 8888
    /** 交易委托撤单 */
    static let orderAction = 8889
    /** 成交回报（push) */
    static let tradeConfirm = 8900
    /** 缓存回报(push) */
    static let cacheConfirm = 901
    /** 期权委托行权 */
    static let execOrderInsert = 8088
    /** 期权委托撤单 */
    static let execOrderAction = 8089
    /** 委托回报 */
    static let entrust = 8901
}

/** 通知名称 */
extension Notification.Name {
    static let socketConnected = Notification.Name("GFMarsSocketConnectedNotification")
    static let socketAuthenticated = Notification.Name("GFMarsSocketAuthenticatedNotification")
    static let socketLoggedIn = Notification.Name("GFMarsSocketLoggedInNotification")
    static let socketAutoLoggedIn = Notification.Name("GFMarsSocketAutoLoggedInNotification")
    static let socketLoggedOut = Notification.Name("GFMarsSocketLoggedOutNotification")
    static let socketDisconnected = Notification.Name("GFMarsSocketDisconnectedNotification")
    static let tradeConfirm = Notification.Name("GFMarsTradeConfirmNotification")
    static let canFetchTradeConfirm = Notification.Name("GFMarsCanFetchTradeConfirmNotification")
    static let entrustNotification = Notification.Name("GFMarsEntrustNotification")
}

/** socket连接的服务端IP */
let GFMarsSocketIP = "lucytradegwtest.gtjaqh.com"
/** socket连接的服务端Port */
let GFMarsSocketPort = 8902
/** socket重试次数 */
let GFMarsSocketRetryCount = 6

let GFMarsFlowNo = "flowNo"
let GFMarsCode = "code"
let GFMarsMsg = "msg"
let GFMarsData = "data"

/** Package Header保留字段本地保存的Key值 */
let GFMarsSocketPackageHeaderReservedKey = "GFMarsSocketPackageHeaderReservedKey"
