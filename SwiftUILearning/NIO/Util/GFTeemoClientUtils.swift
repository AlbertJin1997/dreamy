//
//  ClientUtil.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/15.
//

import Foundation
import SwiftProtobuf

class GFTeemoClientUtils {
    static var RequestToFunIdDic: [String : Int] = [
        // 心跳 funId 1
        "Com_Gtjaqh_Zhuque_Ngate_SystemHeartbeatRequest" : Com_Gtjaqh_Zhuque_Ngate_InterfaceType.systemHeartbeat.rawValue,
        // Zid 申请 2
        "Com_Gtjaqh_Zhuque_Ngate_SystemZIDApplyRequest" : Com_Gtjaqh_Zhuque_Ngate_InterfaceType.systemZidApply.rawValue,
        // 基本信息采集，规定长连接建立后需首先调用
        "Com_Gtjaqh_Zhuque_Ngate_SystemInfoRegisterRequest" : Com_Gtjaqh_Zhuque_Ngate_InterfaceType.systemInfoRegister.rawValue,
        // 主题订阅/取消订阅 50
        "Com_Gtjaqh_Zhuque_Ngate_SubscribeThemeRequest" : Com_Gtjaqh_Zhuque_Ngate_InterfaceType.subscribeTheme.rawValue,
    ]
    
    static var FunIdToResponseDic: [Int : Message.Type] = [
        Com_Gtjaqh_Zhuque_Ngate_InterfaceType.taskDefault.rawValue  : Com_Gtjaqh_Zhuque_Ngate_SystemUnacceptableResponse.self,
        Com_Gtjaqh_Zhuque_Ngate_InterfaceType.systemHeartbeat.rawValue : Com_Gtjaqh_Zhuque_Ngate_SystemHeartbeatResponse.self,
        Com_Gtjaqh_Zhuque_Ngate_InterfaceType.systemZidApply.rawValue : Com_Gtjaqh_Zhuque_Ngate_SystemZIDApplyResponse.self,
        Com_Gtjaqh_Zhuque_Ngate_InterfaceType.systemInfoRegister.rawValue : Com_Gtjaqh_Zhuque_Ngate_SystemInfoRegisterResponse.self,
        Com_Gtjaqh_Zhuque_Ngate_InterfaceType.subscribeTheme.rawValue : Com_Gtjaqh_Zhuque_Ngate_SubscribeThemeResponse.self,
        Com_Gtjaqh_Zhuque_Ngate_InterfaceType.notify.rawValue : Com_Gtjaqh_Zhuque_Ngate_NotifyReturn.self
    ]
}


