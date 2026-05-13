//
//  MyView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

struct MyView: View {
    @EnvironmentObject private var session: AppSession
    
    @StateObject private var viewModel = MyViewModel()

    var body: some View {
        VStack(spacing: 0) {
            AppHeaderView(title: "My")
            
            VStack(spacing: 0) {
                profileSection
                menuList
                Spacer()
            }
            .background(Color(red: 245/255, green: 244/255, blue: 249/255))
        }
        .background(Color.white.ignoresSafeArea(edges: .top))
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("프로필")
                .font(.system(size: 15))
                .foregroundColor(.gray)

            Text("\(viewModel.userName)님")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 36)
        .padding(.vertical, 18)
    }

    private var menuList: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.menuItems) { item in
                Button {
                    viewModel.handleMenuTap(item) {
                        session.logout()
                    }
                } label: {
                    HStack(spacing: 18) {
                        Image(systemName: item.icon)
                            .font(.system(size: 24))
                            .foregroundColor(.black)

                        Text(item.title)
                            .font(.system(size: 19))
                            .foregroundColor(.black)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding(.horizontal, 36)
                    .frame(height: 72)
                    .background(Color.white)
                }

                Divider()
                    .padding(.leading, 22)
            }
        }
    }
}

#Preview {
    MyView()
}
