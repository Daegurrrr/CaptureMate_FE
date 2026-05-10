//
//  RootView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject private var session: AppSession
    
    var body: some View {
        // 개발 테스트용(메인페이지부터 실행됨)
//        MainTabView()
        
        // 실제 앱용
        Group {
            if session.isLoggedIn {
                MainTabView()
            } else if !session.hasSeenIntro {
                IntroPagerView()
            } else {
                AuthEntryView()
            }
        }
    }
}


#Preview {
    RootView()
        .environmentObject(AppSession())
}
