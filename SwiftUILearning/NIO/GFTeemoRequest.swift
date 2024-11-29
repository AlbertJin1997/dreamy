//
//  GFTeemoRequest.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/11/21.
//

import Foundation
import SwiftProtobuf

@objcMembers
public class GFTeemoRequest: NSObject {
    public func sendRequest(message: Message, timeOut: Double = GFTeemoRequestDefaultTimeout, responseHandler: ((GFTeemoResponseModel) -> Void)? = nil) {
        GFTeemoClientManager.shared.sendMessage(message: message, timeOut: timeOut, responseHandler: responseHandler)
    }
}
