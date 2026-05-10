//
//  NotificationRouter.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/10/26.
//

import Foundation

final class NotificationRouter: ObservableObject {
    static let shared = NotificationRouter()

    @Published var shouldOpenAddView: Bool = false

    private init() {}

    func handleNotification(userInfo: [AnyHashable: Any]) {
        guard let destination = userInfo["destination"] as? String else { return }

        if destination == "add" {
            DispatchQueue.main.async {
                self.shouldOpenAddView = true
            }
        }
    }

    func markAddViewOpened() {
        shouldOpenAddView = false
    }
}
