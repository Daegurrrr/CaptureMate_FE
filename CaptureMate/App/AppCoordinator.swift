//
//  AppCoordinator.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

final class AppCoordinator: ObservableObject {
    @Published var selectedTab: MainTab = .home
    @Published var homePath = NavigationPath()
    @Published var categoryPath = NavigationPath()
    @Published var myPath = NavigationPath()

    func push(_ route: AppRoute, on tab: MainTab) {
        switch tab {
        case .home:
            homePath.append(route)
        case .category:
            categoryPath.append(route)
        case .my:
            myPath.append(route)
        }
    }

    func pop(on tab: MainTab) {
        switch tab {
        case .home:
            if !homePath.isEmpty { homePath.removeLast() }
        case .category:
            if !categoryPath.isEmpty { categoryPath.removeLast() }
        case .my:
            if !myPath.isEmpty { myPath.removeLast() }
        }
    }

    func popToRoot(on tab: MainTab) {
        switch tab {
        case .home:
            homePath = NavigationPath()
        case .category:
            categoryPath = NavigationPath()
        case .my:
            myPath = NavigationPath()
        }
    }
}
