//
//  AppHeaderView.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import SwiftUI

struct AppHeaderView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    var showsBackButton: Bool = false
    var showsBellButton: Bool = true

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 20, weight: .semibold))

            HStack {
                if showsBackButton {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                    }
                }

                Spacer()

                if showsBellButton {
                    Button {
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
    }
}
