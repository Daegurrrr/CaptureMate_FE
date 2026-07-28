//
//  AppSession.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

final class AppSession: ObservableObject {
    @AppStorage("hasSeenIntro") var hasSeenIntro: Bool = false
    
    func completeIntro() {
        hasSeenIntro = true
    }
}
