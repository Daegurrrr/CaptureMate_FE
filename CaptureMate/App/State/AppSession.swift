//
//  AppSession.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

final class AppSession: ObservableObject {
    @AppStorage("hasSeenIntro") var hasSeenIntro: Bool = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    func completeIntro() {
        hasSeenIntro = true
    }
    
    func login() {
        isLoggedIn = true
        hasSeenIntro = true
    }
    
    func logout() {
        isLoggedIn = false
    }
}
