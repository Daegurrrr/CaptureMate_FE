//
//  LoginViewModel.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/10/26.
//

import Foundation
import SwiftUI

final class LoginViewModel: ObservableObject {

    func loginWithApple(identityToken: String) {

        print("Apple Login Success")
        print(identityToken)
    }
}
