//
//  MyMenuItem.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/12/26.
//

import Foundation

struct MyMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let type: MyMenuType
}

enum MyMenuType {
    case notificationSetting
    case permissionSetting
}
