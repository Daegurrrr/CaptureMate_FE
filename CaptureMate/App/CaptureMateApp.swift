//
//  CaptureMateApp.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

@main
struct CaptureMateApp: App {
    @StateObject private var session = AppSession()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
        }
    }
}

