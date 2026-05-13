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
            imageName: "sample_cature_1.png",
            category: .place,
            title: "성수 카페 캡처",
            summary: "성수 카페 추천 서울 성동구 성수동"
        ),

        ScreenshotItem(
            imageName: "sample_cature_2.png",
            category: .schedule,
            title: "무신사 할인 이벤트",
            summary: "무신사 최대 30% 할인 3월 31일까지"
        ),

        ScreenshotItem(
            imageName: "sample_cature_3.png",
            category: .schedule,
            title: "전시회 일정",
            summary: "전시회 4월 5일 오후 2시 시작"
        ),

        ScreenshotItem(
            imageName: "sample_cature_4.png",
            category: .memo,
            title: "맛집 정리",
            summary: "친구가 추천한 맛집 리스트"
        )

    ]

}
