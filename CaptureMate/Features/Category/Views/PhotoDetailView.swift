//
//  PhotoDetailView.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import SwiftUI
import SwiftData
import MapKit
import UIKit

struct PhotoDetailView: View {
    let photo: CategoryPhotoItem

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showCaption = false
    @State private var analysisRecord: PhotoAnalysisRecord?
    @State private var selectedPlaceIndex = 0
    @State private var selectedShoppingIndex = 0
    @State private var selectedScheduleIndex = 0

    var body: some View {
        ZStack {
            Color(
                red: 243 / 255,
                green: 242 / 255,
                blue: 249 / 255
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                Image(uiImage: photo.image)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 12)

                Spacer()
            }

            VStack {
                HStack {
                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        Color.black.opacity(0.08),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(
                                color: .black.opacity(0.18),
                                radius: 8,
                                x: 0,
                                y: 3
                            )
                    }
                    .padding(.top, 12)
                    .padding(.trailing, 14)
                }

                Spacer()
            }

            VStack {
                Spacer()

                VStack(spacing: 12) {
                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 42, height: 5)

                    Text("캡쳐 정보")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)

                    VStack(alignment: .leading, spacing: 8) {
                        if isUnknownCategory {
                            EmptyView()
                        } else if let actionData = analysisRecord?.actionData,
                           !actionData.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 14) {
                                    let sections = analysisSections(from: actionData)
                                    let places = placeDetails(from: sections)
                                    let shoppingItems = shoppingDetails(from: sections)
                                    let schedules = scheduleDetails(from: sections)

                                    if places.count > 1 {
                                        MultiPlaceMapSection(
                                            places: places,
                                            selectedIndex: $selectedPlaceIndex
                                        )
                                    }

                                    if shoppingItems.count > 1 {
                                        MultiShoppingLinkSection(
                                            items: shoppingItems,
                                            selectedIndex: $selectedShoppingIndex
                                        )
                                    }

                                    if schedules.count > 1 {
                                        MultiScheduleSection(
                                            schedules: schedules,
                                            selectedIndex: $selectedScheduleIndex
                                        )
                                    }

                                    ForEach(
                                        Array(sections.enumerated()),
                                        id: \.offset
                                    ) { _, lines in
                                        analysisSectionView(
                                            lines: lines,
                                            showsMap: places.count <= 1,
                                            showsPlaceLink: places.count <= 1,
                                            showsShoppingLink: shoppingItems.count <= 1,
                                            hidesShoppingTitle: shoppingItems.count > 1,
                                            hidesScheduleSection: schedules.count > 1
                                        )
                                    }
                                }
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                            }
                            .frame(maxHeight: 220)
                        } else {
                            Text("저장된 분석 결과가 없어요.")
                                .font(.system(size: 13))
                                .foregroundColor(.black.opacity(0.56))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 34)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 24,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 24
                    )
                )
                .overlay(alignment: .bottom) {
                    Color.white
                        .frame(height: 120)
                        .offset(y: 120)
                        .allowsHitTesting(false)
                }
                .offset(y: showCaption ? 0 : 220)
                .animation(.spring(), value: showCaption)
            }
        }
        .onAppear {
            loadAnalysis()
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height < -40 {
                        showCaption = true
                    } else if value.translation.height > 40 {
                        showCaption = false
                    }
                }
        )
    }

    private var isUnknownCategory: Bool {
        let category = analysisRecord?.category?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return category == "기타" || category == "unknown"
    }

    private func loadAnalysis() {
        let localId = photo.id

        let descriptor = FetchDescriptor<PhotoAnalysisRecord>(
            predicate: #Predicate { $0.localIdentifier == localId }
        )

        analysisRecord = try? modelContext.fetch(descriptor).first
    }

    private func analysisSections(from text: String) -> [[String]] {
        text.components(separatedBy: "\n\n")
            .map { section in
                section
                    .split(separator: "\n")
                    .map { String($0) }
                    .filter { !$0.isEmpty }
            }
            .filter { !$0.isEmpty }
    }

    @ViewBuilder
    private func analysisSectionView(
        lines: [String],
        showsMap: Bool = true,
        showsPlaceLink: Bool = true,
        showsShoppingLink: Bool = true,
        hidesShoppingTitle: Bool = false,
        hidesScheduleSection: Bool = false
    ) -> some View {
        let titleLine = lines.first
        let title = titleLine.flatMap(headlineTitle)
        let hidesTitle = hidesShoppingTitle && (titleLine?.hasPrefix("상품명:") == true)
        let hidesSection = hidesScheduleSection && (titleLine?.hasPrefix("일정명:") == true)
        let detailLines = title == nil ? lines : Array(lines.dropFirst())
        let coordinate = coordinate(from: lines)
        let schedule = scheduleDetail(from: lines)

        if !hidesSection {
            VStack(alignment: .leading, spacing: 8) {
                if let title, !hidesTitle {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                }

                if showsMap, let coordinate {
                    LocationMapPreview(coordinate: coordinate)
                }

                if !detailLines.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(
                            Array(detailLines.enumerated()),
                            id: \.offset
                        ) { _, line in
                            analysisDetailLineView(
                                line,
                                showsPlaceLink: showsPlaceLink,
                                showsShoppingLink: showsShoppingLink
                            )
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }

                if let schedule {
                    ScheduleCalendarButton(schedule: schedule)
                }
            }
        }
    }

    @ViewBuilder
    private func analysisDetailLineView(
        _ line: String,
        showsPlaceLink: Bool = true,
        showsShoppingLink: Bool = true
    ) -> some View {
        if shouldHideDetailLine(line) {
            EmptyView()
        } else if line.hasPrefix("지도 링크:") && !showsPlaceLink {
            EmptyView()
        } else if isShoppingLinkLine(line) && !showsShoppingLink {
            EmptyView()
        } else if let urlText = extractURL(from: line),
           let url = URL(string: urlText) {
            Link(destination: url) {
                HStack(spacing: 4) {
                    Text(linkTitle(from: line))
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.blue)
            }
        } else {
            Text(displayValue(from: line))
                .font(.system(size: 13))
                .foregroundColor(.black.opacity(0.68))
                .lineSpacing(4)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
    }

    private func shouldHideDetailLine(_ line: String) -> Bool {
        let hiddenPrefixes = [
            "좌표:",
            "위도:",
            "경도:",
            "지도 제공:"
        ]

        return hiddenPrefixes.contains { line.hasPrefix($0) }
    }

    private func coordinate(from lines: [String]) -> CLLocationCoordinate2D? {
        if let coordinateLine = lines.first(where: { $0.hasPrefix("좌표:") }) {
            return coordinate(fromCombinedText: displayValue(from: coordinateLine))
        }

        guard let latitudeLine = lines.first(where: { $0.hasPrefix("위도:") }),
              let longitudeLine = lines.first(where: { $0.hasPrefix("경도:") }),
              let latitude = Double(displayValue(from: latitudeLine)),
              let longitude = Double(displayValue(from: longitudeLine)) else {
            return nil
        }

        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }

    private func coordinate(fromCombinedText text: String) -> CLLocationCoordinate2D? {
        let values = text
            .split(separator: ",")
            .map {
                String($0)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .compactMap(Double.init)

        guard values.count == 2 else {
            return nil
        }

        return CLLocationCoordinate2D(
            latitude: values[0],
            longitude: values[1]
        )
    }

    private func placeDetails(from sections: [[String]]) -> [PlaceDetail] {
        sections.compactMap { lines in
            guard let titleLine = lines.first(where: { $0.hasPrefix("장소명:") }),
                  let linkLine = lines.first(where: { $0.hasPrefix("지도 링크:") }),
                  let urlText = extractURL(from: linkLine),
                  let url = URL(string: urlText) else {
                return nil
            }

            let address = lines
                .first(where: { $0.hasPrefix("주소:") })
                .map { displayValue(from: $0) }

            return PlaceDetail(
                name: displayValue(from: titleLine),
                address: address,
                coordinate: coordinate(from: lines),
                url: url
            )
        }
    }

    private func shoppingDetails(from sections: [[String]]) -> [ShoppingDetail] {
        sections.compactMap { lines in
            guard let titleLine = lines.first(where: { $0.hasPrefix("상품명:") }) else {
                return nil
            }

            let shoppingURL = url(from: lines, prefix: "쇼핑 링크:")
            let brandURL = url(from: lines, prefix: "브랜드 링크:")

            guard shoppingURL != nil || brandURL != nil else {
                return nil
            }

            return ShoppingDetail(
                name: displayValue(from: titleLine),
                shoppingURL: shoppingURL,
                brandURL: brandURL
            )
        }
    }

    private func scheduleDetails(from sections: [[String]]) -> [ScheduleDetail] {
        sections.compactMap { lines in
            scheduleDetail(from: lines)
        }
    }

    private func scheduleDetail(from lines: [String]) -> ScheduleDetail? {
        guard let titleLine = lines.first(where: { $0.hasPrefix("일정명:") }) else {
            return nil
        }

        return ScheduleDetail(
            title: displayValue(from: titleLine),
            startAt: value(from: lines, prefix: "시작:"),
            endAt: value(from: lines, prefix: "종료:"),
            startDate: value(from: lines, prefix: "시작:")
                .flatMap(parseDate),
            endDate: value(from: lines, prefix: "종료:")
                .flatMap(parseDate)
        )
    }

    private func parseDate(from text: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date = isoFormatter.date(from: text) {
            return date
        }

        let simpleISOFormatter = DateFormatter()
        simpleISOFormatter.locale = Locale(identifier: "ko_KR")
        simpleISOFormatter.timeZone = TimeZone.current
        simpleISOFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        if let date = simpleISOFormatter.date(from: text) {
            return date
        }

        let dateOnlyFormatter = DateFormatter()
        dateOnlyFormatter.locale = Locale(identifier: "ko_KR")
        dateOnlyFormatter.timeZone = TimeZone.current
        dateOnlyFormatter.dateFormat = "yyyy-MM-dd"

        if let date = dateOnlyFormatter.date(from: text) {
            return date
        }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ko_KR")
        displayFormatter.timeZone = TimeZone.current
        displayFormatter.dateFormat = "yyyy.MM.dd HH:mm"

        return displayFormatter.date(from: text)
    }

    private func value(from lines: [String], prefix: String) -> String? {
        lines
            .first(where: { $0.hasPrefix(prefix) })
            .map { displayValue(from: $0) }
    }

    private func url(from lines: [String], prefix: String) -> URL? {
        guard let line = lines.first(where: { $0.hasPrefix(prefix) }),
              let urlText = extractURL(from: line) else {
            return nil
        }

        return URL(string: urlText)
    }

    private func isShoppingLinkLine(_ line: String) -> Bool {
        line.hasPrefix("쇼핑 링크:")
            || line.hasPrefix("브랜드 링크:")
    }

    private func headlineTitle(from line: String) -> String? {
        let prefixes = [
            "일정명:",
            "장소명:",
            "상품명:",
            "제목:"
        ]

        guard let prefix = prefixes.first(where: { line.hasPrefix($0) }) else {
            return nil
        }

        return String(line.dropFirst(prefix.count))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractURL(from text: String) -> String? {
        let pattern = #"(https?://|kakaomap://)[^\s]+"#

        guard let range = text.range(
            of: pattern,
            options: .regularExpression
        ) else {
            return nil
        }

        return String(text[range])
            .trimmingCharacters(in: CharacterSet(charactersIn: ".,)]}"))
    }

    private func linkTitle(from line: String) -> String {
        if line.hasPrefix("지도 링크:") {
            return "장소 보기"
        }

        if line.hasPrefix("쇼핑 링크:") {
            return "상품 보기"
        }

        if line.hasPrefix("브랜드 링크:") {
            return "브랜드 보기"
        }

        return "링크 열기"
    }

    private func displayValue(from line: String) -> String {
        guard let separatorRange = line.range(of: ":") else {
            return line
        }

        return String(line[separatorRange.upperBound...])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct PlaceDetail: Identifiable {
    let id = UUID()
    let name: String
    let address: String?
    let coordinate: CLLocationCoordinate2D?
    let url: URL
}

private struct ShoppingDetail: Identifiable {
    let id = UUID()
    let name: String
    let shoppingURL: URL?
    let brandURL: URL?
}

private struct ScheduleDetail: Identifiable {
    let id = UUID()
    let title: String
    let startAt: String?
    let endAt: String?
    let startDate: Date?
    let endDate: Date?
}

private struct MultiPlaceMapSection: View {
    let places: [PlaceDetail]
    @Binding var selectedIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if places.contains(where: { $0.coordinate != nil }) {
                LocationMapPreview(
                    places: places,
                    selectedIndex: selectedIndex
                )
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(places.enumerated()), id: \.element.id) { index, place in
                        Button {
                            selectedIndex = index
                        } label: {
                            Text(place.name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(
                                    selectedIndex == index ? .white : .black.opacity(0.72)
                                )
                                .lineLimit(1)
                                .padding(.horizontal, 12)
                                .frame(height: 32)
                                .background(
                                    selectedIndex == index
                                    ? Color.blue
                                    : Color.black.opacity(0.06)
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if places.indices.contains(selectedIndex) {
                let selectedPlace = places[selectedIndex]

                VStack(alignment: .leading, spacing: 4) {
                    if let address = selectedPlace.address,
                       !address.isEmpty {
                        Text(address)
                            .font(.system(size: 13))
                            .foregroundColor(.black.opacity(0.68))
                    }

                    Button {
                        UIApplication.shared.open(selectedPlace.url)
                    } label: {
                        HStack(spacing: 4) {
                            Text("장소 보기")
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct MultiScheduleSection: View {
    let schedules: [ScheduleDetail]
    @Binding var selectedIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(schedules.enumerated()), id: \.element.id) { index, schedule in
                        Button {
                            selectedIndex = index
                        } label: {
                            Text(schedule.title)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(
                                    selectedIndex == index ? .white : .black.opacity(0.72)
                                )
                                .lineLimit(1)
                                .padding(.horizontal, 12)
                                .frame(height: 32)
                                .background(
                                    selectedIndex == index
                                    ? Color.blue
                                    : Color.black.opacity(0.06)
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if schedules.indices.contains(selectedIndex) {
                let selectedSchedule = schedules[selectedIndex]

                VStack(alignment: .leading, spacing: 5) {
                    if let startAt = selectedSchedule.startAt,
                       !startAt.isEmpty {
                        Text(startAt)
                            .font(.system(size: 13))
                            .foregroundColor(.black.opacity(0.68))
                    }

                    if let endAt = selectedSchedule.endAt,
                       !endAt.isEmpty {
                        Text(endAt)
                            .font(.system(size: 13))
                            .foregroundColor(.black.opacity(0.68))
                    }

                    ScheduleCalendarButton(schedule: selectedSchedule)
                }
            }
        }
    }
}

private struct ScheduleCalendarButton: View {
    let schedule: ScheduleDetail

    @State private var showPermissionAlert = false
    @State private var showSaveFailedAlert = false

    var body: some View {
        if let startDate = schedule.startDate {
            Button {
                saveToCalendar(startDate: startDate)
            } label: {
                LinkLabel(title: "캘린더 보기")
            }
            .buttonStyle(.plain)
            .alert("캘린더 권한이 필요해요", isPresented: $showPermissionAlert) {
                Button("취소", role: .cancel) {}

                Button("설정 열기") {
                    Task {
                        await CalendarService.shared.openAppSettings()
                    }
                }
            } message: {
                Text("일정을 저장하려면 설정에서 캘린더 접근 권한을 허용해주세요.")
            }
            .alert("캘린더 저장에 실패했어요", isPresented: $showSaveFailedAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("잠시 후 다시 시도해주세요.")
            }
        }
    }

    private func saveToCalendar(startDate: Date) {
        let endDate = schedule.endDate ?? Calendar.current.date(
            byAdding: .hour,
            value: 1,
            to: startDate
        ) ?? startDate

        Task {
            let result = await CalendarService.shared.addEventWithResult(
                title: schedule.title,
                startDate: startDate,
                endDate: endDate
            )

            switch result {
            case .success:
                await CalendarService.shared.openCalendarApp(at: startDate)

            case .permissionDenied:
                await MainActor.run {
                    showPermissionAlert = true
                }

            case .failure:
                await MainActor.run {
                    showSaveFailedAlert = true
                }
            }
        }
    }
}

private struct MultiShoppingLinkSection: View {
    let items: [ShoppingDetail]
    @Binding var selectedIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        Button {
                            selectedIndex = index
                        } label: {
                            Text(item.name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(
                                    selectedIndex == index ? .white : .black.opacity(0.72)
                                )
                                .lineLimit(1)
                                .padding(.horizontal, 12)
                                .frame(height: 32)
                                .background(
                                    selectedIndex == index
                                    ? Color.blue
                                    : Color.black.opacity(0.06)
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if items.indices.contains(selectedIndex) {
                let selectedItem = items[selectedIndex]

                VStack(alignment: .leading, spacing: 6) {
                    if let shoppingURL = selectedItem.shoppingURL {
                        Button {
                            UIApplication.shared.open(shoppingURL)
                        } label: {
                            LinkLabel(title: "상품 보기")
                        }
                        .buttonStyle(.plain)
                    }

                    if let brandURL = selectedItem.brandURL {
                        Button {
                            UIApplication.shared.open(brandURL)
                        } label: {
                            LinkLabel(title: "브랜드 보기")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct LinkLabel: View {
    let title: String

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
            Image(systemName: "arrow.up.right")
                .font(.system(size: 11, weight: .semibold))
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundColor(.blue)
    }
}

private struct LocationMapPreview: View {
    let places: [PlaceDetail]
    let selectedIndex: Int?

    init(coordinate: CLLocationCoordinate2D) {
        places = [
            PlaceDetail(
                name: "위치",
                address: nil,
                coordinate: coordinate,
                url: URL(string: "https://maps.apple.com")!
            )
        ]
        selectedIndex = nil
    }

    init(places: [PlaceDetail], selectedIndex: Int) {
        self.places = places
        self.selectedIndex = selectedIndex
    }

    var body: some View {
        Map(
            initialPosition: .region(
                region
            )
        ) {
            ForEach(Array(places.enumerated()), id: \.element.id) { index, place in
                if let coordinate = place.coordinate {
                    Marker(
                        markerTitle(for: place, index: index),
                        coordinate: coordinate
                    )
                }
            }
        }
        .frame(height: 132)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .allowsHitTesting(false)
    }

    private var region: MKCoordinateRegion {
        let coordinates = places.compactMap(\.coordinate)

        guard coordinates.count > 1 else {
            return MKCoordinateRegion(
                center: coordinates.first ?? CLLocationCoordinate2D(
                    latitude: 37.5665,
                    longitude: 126.9780
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.004,
                    longitudeDelta: 0.004
                )
            )
        }

        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        let minLatitude = latitudes.min() ?? 37.5665
        let maxLatitude = latitudes.max() ?? 37.5665
        let minLongitude = longitudes.min() ?? 126.9780
        let maxLongitude = longitudes.max() ?? 126.9780

        let latitudeDelta = max((maxLatitude - minLatitude) * 1.6, 0.004)
        let longitudeDelta = max((maxLongitude - minLongitude) * 1.6, 0.004)

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLatitude + maxLatitude) / 2,
                longitude: (minLongitude + maxLongitude) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: latitudeDelta,
                longitudeDelta: longitudeDelta
            )
        )
    }

    private func markerTitle(for place: PlaceDetail, index: Int) -> String {
        if selectedIndex == index {
            return "선택됨"
        }

        return place.name
    }
}
