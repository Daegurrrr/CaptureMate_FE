//
//  HomeHeaderView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

//
//  HomeHeaderView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct HomeHeaderView: View {
    var body: some View {
        ZStack {
            Text("Home")
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

#Preview {
    HomeHeaderView()
}
