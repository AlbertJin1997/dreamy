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

/** 心跳间隔 */
let GFTeemoHeartBeatInterval: TimeInterval = 30

/** Socket包的包头长度 */
let GFTeemoPackageHeaderLen: Int = 12

// FuncId定义
struct GFTeemoFuncId {
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
    static let socketConnected = Notification.Name("GFTeemoSocketConnectedNotification")
    static let socketAuthenticated = Notification.Name("GFTeemoSocketAuthenticatedNotification")
    static let socketLoggedIn = Notification.Name("GFTeemoSocketLoggedInNotification")
    static let socketAutoLoggedIn = Notification.Name("GFTeemoSocketAutoLoggedInNotification")
    static let socketLoggedOut = Notification.Name("GFTeemoSocketLoggedOutNotification")
    static let socketDisconnected = Notification.Name("GFTeemoSocketDisconnectedNotification")
    static let tradeConfirm = Notification.Name("GFTeemoTradeConfirmNotification")
    static let canFetchTradeConfirm = Notification.Name("GFTeemoCanFetchTradeConfirmNotification")
    static let entrustNotification = Notification.Name("GFTeemoEntrustNotification")
}

/** socket连接的服务端IP */
let GFTeemoSocketIP = "lucytradegwtest.gtjaqh.com"
/** socket连接的服务端Port */
let GFTeemoSocketPort = 8902
/** socket重试次数 */
let GFTeemoSocketRetryCount = 6
/** 头部固定长度*/
let GFTeemoHeaderLength = 12

let GFTeemoFlowNo = "flowNo"
let GFTeemoCode = "code"
let GFTeemoMsg = "msg"
let GFTeemoData = "data"

/** Package Header保留字段本地保存的Key值 */
let GFTeemoSocketPackageHeaderReservedKey = "GFTeemoSocketPackageHeaderReservedKey"
