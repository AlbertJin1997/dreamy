//
//  GFTeemoRequestModel.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/19.
//

import Foundation

class GFTeemoRequestModel {
    var funcId: Int
    var requestTimeStamp: Double
    var timeOut: Double
    var responseHandler: ((GFTeemoResponseModel) -> Void)? // 可选闭包
    
    // 初始化方法
    init(funcId: Int,
         requestTimeStamp: Double = Date().timeIntervalSince1970,
         timeOut: Double = GFTeemoRequestDefaultTimeout,
         responseHandler: ((GFTeemoResponseModel) -> Void)? = nil) {
        self.funcId = funcId
        self.requestTimeStamp = requestTimeStamp
        self.timeOut = timeOut
        self.responseHandler = responseHandler
    }
}

