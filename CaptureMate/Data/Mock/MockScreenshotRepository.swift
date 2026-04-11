//
//  MockScreenshotRepository.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import Foundation

struct MockScreenshotRepository {

    static let items: [ScreenshotItem] = [

        ScreenshotItem(
            title: "성수 카페 캡처",
            subtitle: "서울 성동구 성수동",
            category: .place,
            extractedText: "성수 카페 추천 서울 성동구 성수동"
        ),

        ScreenshotItem(
            title: "무신사 할인 이벤트",
            subtitle: "3월 31일까지 할인",
            category: .discount,
            extractedText: "무신사 최대 30% 할인 3월 31일까지"
        ),

        ScreenshotItem(
            title: "전시회 일정",
            subtitle: "4월 5일 오후 2시",
            category: .schedule,
            extractedText: "전시회 4월 5일 오후 2시 시작"
        ),

        ScreenshotItem(
            title: "맛집 정리",
            subtitle: "친구 추천 맛집",
            category: .memo,
            extractedText: "친구가 추천한 맛집 리스트"
        )

    ]

}
