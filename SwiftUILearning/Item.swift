//
//  Item.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/9/12.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
