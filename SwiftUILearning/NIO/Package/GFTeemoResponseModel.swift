//
//  GFTeemoResponseModel.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/19.
//

import Foundation
import SwiftProtobuf

class GFTeemoResponseModel {
    var success: Bool
    var data: Message?
    var errMsg: String

    // 初始化方法
    init(success: Bool, data: Message, errMsg: String) {
        self.success = success
        self.data = data
        self.errMsg = errMsg
    }
}
