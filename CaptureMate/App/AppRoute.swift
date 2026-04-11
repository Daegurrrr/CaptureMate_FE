//
//  AppRoute.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import Foundation

enum AppRoute: Hashable {
    case captureDetail(item: ScreenshotItem)
    case result(item: ScreenshotItem)
    case place(placeInfo: PlaceInfo)
    case coupon(couponInfo: CouponInfo)
    case calendar(scheduleInfo: ScheduleInfo)
}
