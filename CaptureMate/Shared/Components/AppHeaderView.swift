//
//  AppHeaderView.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import SwiftUI

struct AppHeaderView: View {
    let title: String

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 20, weight: .semibold))

            HStack {
                Spacer()

                Button {
                } label: {
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
    }
}
