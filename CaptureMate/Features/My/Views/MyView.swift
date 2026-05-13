//
//  MyView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

struct MyView: View {
    @StateObject private var viewModel = MyViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerView

            profileSection

            menuList

            Spacer()
        }
        .background(Color.white)
    }

    private var headerView: some View {
        ZStack {
            Text("My")
                .font(.system(size: 18, weight: .semibold))

            HStack {
                Spacer()

                Button {
                    print("알림 버튼 클릭")
                } label: {
                    Image(systemName: "bell")
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 22)
        }
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 24) {
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
                    viewModel.handleMenuTap(item)
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
