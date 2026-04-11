//
//  MainTabView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(MainTab.home)

            Text("Category")
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("Category")
                }
                .tag(MainTab.category)

            Text("Add")
                .tabItem {
                    Image(systemName: "plus")
                    Text("Add")
                }
                .tag(MainTab.add)

            Text("Map")
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
                .tag(MainTab.map)

            Text("My")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("My")
                }
                .tag(MainTab.my)
        }
    }
}

#Preview {
    MainTabView()
}
