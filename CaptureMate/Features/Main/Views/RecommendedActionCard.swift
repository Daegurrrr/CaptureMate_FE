//
//  RecommendedActionCard.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct RecommendedActionCard: View {

    let actions: [RecommendedAction]
    let onDelete: (RecommendedAction) -> Void

    var body: some View {

        VStack(spacing: 0) {

            if actions.isEmpty {

                Text("추천 액션이 아직 없어요")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)

            } else {

                ForEach(actions) { action in

                    RecommendedActionRow(

                        action: action,

                        onTap: {
                            handleAction(action)
                        },

                        onDelete: {
                            onDelete(action)
                        }
                    )

                    if action.id != actions.last?.id {

                        Divider()
                            .padding(.leading, 46)

                    }
                }
            }
        }
        .background(Color.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }

    private func handleAction(
        _ action: RecommendedAction
    ) {

        switch action.type {

        case .place, .shopping:

            guard let urlString = action.url,
                  let url = URL(string: urlString)
            else {
                return
            }

            UIApplication.shared.open(url)

        case .schedule:

            print(
                "캘린더 연결 예정:",
                action.title
            )
        }
    }
}
