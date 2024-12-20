// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: ZhuQueEnum.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

// Author      : meiyu024717@gtjas.com
// Version     : ZQE_V0.1
// Update      : 2024/10/30
// Discription : ZhuQue Notification Gate Platform 朱雀通知网关平台数据枚举类型

import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// 主题订阅theme_url类型
enum Com_Gtjaqh_Zhuque_ThemeUrlTypeType: SwiftProtobuf.Enum, Swift.CaseIterable {
  typealias RawValue = Int

  /// 默认填充
  case tuttDefault // = 0

  /// 单一指定主题
  case tuttExact // = 1

  /// 包含子主题
  case tuttChilds // = 2
  case UNRECOGNIZED(Int)

  init() {
    self = .tuttDefault
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .tuttDefault
    case 1: self = .tuttExact
    case 2: self = .tuttChilds
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .tuttDefault: return 0
    case .tuttExact: return 1
    case .tuttChilds: return 2
    case .UNRECOGNIZED(let i): return i
    }
  }

  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static let allCases: [Com_Gtjaqh_Zhuque_ThemeUrlTypeType] = [
    .tuttDefault,
    .tuttExact,
    .tuttChilds,
  ]

}

/// 用户认证类型
enum Com_Gtjaqh_Zhuque_UserVerificationTypeType: SwiftProtobuf.Enum, Swift.CaseIterable {
  typealias RawValue = Int

  /// 默认填充/匿名
  case uvttDefault // = 0

  /// 手机号认证
  case uvttMobile // = 1

  /// 资金账号认证
  case uvttAccount // = 2

  /// 超体用户认证
  case uvttLucyuser // = 3
  case UNRECOGNIZED(Int)

  init() {
    self = .uvttDefault
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .uvttDefault
    case 1: self = .uvttMobile
    case 2: self = .uvttAccount
    case 3: self = .uvttLucyuser
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .uvttDefault: return 0
    case .uvttMobile: return 1
    case .uvttAccount: return 2
    case .uvttLucyuser: return 3
    case .UNRECOGNIZED(let i): return i
    }
  }

  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static let allCases: [Com_Gtjaqh_Zhuque_UserVerificationTypeType] = [
    .uvttDefault,
    .uvttMobile,
    .uvttAccount,
    .uvttLucyuser,
  ]

}

/// 推送类型
enum Com_Gtjaqh_Zhuque_PushTypeType: SwiftProtobuf.Enum, Swift.CaseIterable {
  typealias RawValue = Int

  /// 默认填充
  case pttDefault // = 0

  /// 持久化推送，重连重传
  case pttPromise // = 1

  /// 流水推送，只推送在线发布的新消息
  case pttFlow // = 2

  /// 最新推送，登录时推送一条最新消息，在线时推送更新消息
  case pttLatest // = 3
  case UNRECOGNIZED(Int)

  init() {
    self = .pttDefault
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .pttDefault
    case 1: self = .pttPromise
    case 2: self = .pttFlow
    case 3: self = .pttLatest
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .pttDefault: return 0
    case .pttPromise: return 1
    case .pttFlow: return 2
    case .pttLatest: return 3
    case .UNRECOGNIZED(let i): return i
    }
  }

  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static let allCases: [Com_Gtjaqh_Zhuque_PushTypeType] = [
    .pttDefault,
    .pttPromise,
    .pttFlow,
    .pttLatest,
  ]

}

/// 消息状态
enum Com_Gtjaqh_Zhuque_NotificationStatusType: SwiftProtobuf.Enum, Swift.CaseIterable {
  typealias RawValue = Int

  /// 默认填充
  case nstDefault // = 0

  /// 正常状态
  case nstAlive // = 1

  /// 已过期
  case nstExpired // = 2

  /// 已删除
  case nstDeleted // = 3
  case UNRECOGNIZED(Int)

  init() {
    self = .nstDefault
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .nstDefault
    case 1: self = .nstAlive
    case 2: self = .nstExpired
    case 3: self = .nstDeleted
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .nstDefault: return 0
    case .nstAlive: return 1
    case .nstExpired: return 2
    case .nstDeleted: return 3
    case .UNRECOGNIZED(let i): return i
    }
  }

  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static let allCases: [Com_Gtjaqh_Zhuque_NotificationStatusType] = [
    .nstDefault,
    .nstAlive,
    .nstExpired,
    .nstDeleted,
  ]

}

/// 内存实时数据变更类型
enum Com_Gtjaqh_Zhuque_RealTimeDataUpdateType: SwiftProtobuf.Enum, Swift.CaseIterable {
  typealias RawValue = Int

  /// 默认填充
  case rtdutDefault // = 0

  /// 数据变更
  case rtdutUpdate // = 1

  /// 数据过期
  case rtdutExpire // = 2

  /// 数据删除
  case rtdutDelete // = 3
  case UNRECOGNIZED(Int)

  init() {
    self = .rtdutDefault
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .rtdutDefault
    case 1: self = .rtdutUpdate
    case 2: self = .rtdutExpire
    case 3: self = .rtdutDelete
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .rtdutDefault: return 0
    case .rtdutUpdate: return 1
    case .rtdutExpire: return 2
    case .rtdutDelete: return 3
    case .UNRECOGNIZED(let i): return i
    }
  }

  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static let allCases: [Com_Gtjaqh_Zhuque_RealTimeDataUpdateType] = [
    .rtdutDefault,
    .rtdutUpdate,
    .rtdutExpire,
    .rtdutDelete,
  ]

}

/// 数据源类型
enum Com_Gtjaqh_Zhuque_DataSrcType: SwiftProtobuf.Enum, Swift.CaseIterable {
  typealias RawValue = Int

  /// 默认填充
  case dstDefault // = 0

  /// NGate 通知网关功能返回
  case dstNgate // = 1

  /// core 核心实时
  case dstCoreLatest // = 2

  /// 数据库缓存
  case dstDbCache // = 3

  /// NGate 网关缓存
  case dstNgateCache // = 4
  case UNRECOGNIZED(Int)

  init() {
    self = .dstDefault
  }

  init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .dstDefault
    case 1: self = .dstNgate
    case 2: self = .dstCoreLatest
    case 3: self = .dstDbCache
    case 4: self = .dstNgateCache
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  var rawValue: Int {
    switch self {
    case .dstDefault: return 0
    case .dstNgate: return 1
    case .dstCoreLatest: return 2
    case .dstDbCache: return 3
    case .dstNgateCache: return 4
    case .UNRECOGNIZED(let i): return i
    }
  }

  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static let allCases: [Com_Gtjaqh_Zhuque_DataSrcType] = [
    .dstDefault,
    .dstNgate,
    .dstCoreLatest,
    .dstDbCache,
    .dstNgateCache,
  ]

}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension Com_Gtjaqh_Zhuque_ThemeUrlTypeType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "TUTT_DEFAULT"),
    1: .same(proto: "TUTT_EXACT"),
    2: .same(proto: "TUTT_CHILDS"),
  ]
}

extension Com_Gtjaqh_Zhuque_UserVerificationTypeType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "UVTT_DEFAULT"),
    1: .same(proto: "UVTT_MOBILE"),
    2: .same(proto: "UVTT_ACCOUNT"),
    3: .same(proto: "UVTT_LUCYUSER"),
  ]
}

extension Com_Gtjaqh_Zhuque_PushTypeType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "PTT_DEFAULT"),
    1: .same(proto: "PTT_PROMISE"),
    2: .same(proto: "PTT_FLOW"),
    3: .same(proto: "PTT_LATEST"),
  ]
}

extension Com_Gtjaqh_Zhuque_NotificationStatusType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "NST_DEFAULT"),
    1: .same(proto: "NST_ALIVE"),
    2: .same(proto: "NST_EXPIRED"),
    3: .same(proto: "NST_DELETED"),
  ]
}

extension Com_Gtjaqh_Zhuque_RealTimeDataUpdateType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "RTDUT_DEFAULT"),
    1: .same(proto: "RTDUT_UPDATE"),
    2: .same(proto: "RTDUT_EXPIRE"),
    3: .same(proto: "RTDUT_DELETE"),
  ]
}

extension Com_Gtjaqh_Zhuque_DataSrcType: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "DST_DEFAULT"),
    1: .same(proto: "DST_NGATE"),
    2: .same(proto: "DST_CORE_LATEST"),
    3: .same(proto: "DST_DB_CACHE"),
    4: .same(proto: "DST_NGATE_CACHE"),
  ]
}
