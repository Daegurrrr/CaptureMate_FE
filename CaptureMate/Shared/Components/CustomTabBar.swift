//
//  CustomTabBar.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack {
            tabItem(icon: "diamond.fill", title: "Home", tab: .home)
            tabItem(icon: "circle.grid.2x2.fill", title: "Category", tab: .category)
            tabItem(icon: "square.fill", title: "My", tab: .my)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 18)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 8, y: -2)
    }

    @ViewBuilder
    private func tabItem(icon: String, title: String, tab: MainTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))

                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(selectedTab == tab ? .blue : .black)
            .frame(maxWidth: .infinity)
        }
    }
}
