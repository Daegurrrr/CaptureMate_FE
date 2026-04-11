//
//  HomeHeaderView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct HomeHeaderView: View {
    var body: some View {
        HStack {
            Button {
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Label")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
            }

            Spacer()

            Text("Home")
                .font(.system(size: 20, weight: .semibold))

            Spacer()

            Button {
            } label: {
                Image(systemName: "bell")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
    }
}

#Preview {
    HomeHeaderView()
}
