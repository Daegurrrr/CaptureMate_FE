//
//  PhotoDetailView.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import SwiftUI
import SwiftData
import MapKit

struct PhotoDetailView: View {
    let photo: CategoryPhotoItem

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showCaption = false
    @State private var analysisRecord: PhotoAnalysisRecord?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

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
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
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
                        Text(displayTitle())
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                        
                        if let bodyText = displayBodyText(),
                           !bodyText.isEmpty {

                            Text(makeLinkedText(from: bodyText))
                                .font(.system(size: 13))
                                .tint(.blue)
                        } else {
                            Text("저장된 분석 결과가 없어요.")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        
                        if analysisRecord?.category == "장소",
                           let place = parsedPlaceFromActionData() {

                            AppleMapView(
                                latitude: place.latitude,
                                longitude: place.longitude,
                                title: place.title
                            )
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 34)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
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

    private func loadAnalysis() {
        let localId = photo.id

        let descriptor = FetchDescriptor<PhotoAnalysisRecord>(
            predicate: #Predicate { $0.localIdentifier == localId }
        )

        analysisRecord = try? modelContext.fetch(descriptor).first
        print("keywords =", analysisRecord?.keywords ?? [])
        print("category:", analysisRecord?.category ?? "nil")
        print("actionType:", analysisRecord?.actionType ?? "nil")
        print("actionData:", analysisRecord?.actionData ?? "nil")
        print("keywords:", analysisRecord?.keywords ?? [])
    }
    
    private func makeLinkedText(from text: String) -> AttributedString {
        var attributedString = AttributedString(text)

        let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        )

        let range = NSRange(text.startIndex..<text.endIndex, in: text)

        detector?
            .matches(in: text, options: [], range: range)
            .forEach { match in
                guard let url = match.url,
                      let stringRange = Range(match.range, in: text),
                      let attributedRange = Range(stringRange, in: attributedString) else {
                    return
                }

                attributedString[attributedRange].link = url
                attributedString[attributedRange].foregroundColor = .blue
                attributedString[attributedRange].underlineStyle = .single
            }

        return attributedString
    }
    
    private func displayTitle() -> String {
        guard let actionData = analysisRecord?.actionData else {
            return analysisRecord?.category ?? "미분류"
        }

        let items = actionData
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if items.count >= 2 {
            switch analysisRecord?.category {
            case "장소":
                return "장소 리스트"
            case "쇼핑":
                return "쇼핑 리스트"
            case "일정":
                return "일정 리스트"
            case "메모":
                return "메모 리스트"
            default:
                return "분석 결과"
            }
        }

        let lines = actionData
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return lines.first ?? analysisRecord?.category ?? "미분류"
    }
    
    private func displayBodyText() -> String? {
        guard let actionData = analysisRecord?.actionData else {
            return nil
        }

        let items = actionData
            .components(separatedBy: "\n\n")
            .map { item in
                item.components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                    .filter {
                        !$0.hasPrefix("latitude:") &&
                        !$0.hasPrefix("longitude:")
                    }
            }
            .filter { !$0.isEmpty }

        if analysisRecord?.category == "일정" {
            if items.count >= 2 {
                return items.map { lines in
                    let title = lines.first ?? ""
                    let scheduleText = formattedScheduleBody(from: lines) ?? ""

                    return [title, scheduleText]
                        .filter { !$0.isEmpty }
                        .joined(separator: "\n")
                }
                .joined(separator: "\n\n")
            }

            guard let lines = items.first else {
                return nil
            }

            return formattedScheduleBody(from: lines)
        }

        let formattedItems = items.map { lines in
            lines
                .map { formattedBodyLine($0) }
                .joined(separator: "\n")
        }

        if formattedItems.count >= 2 {
            return formattedItems.joined(separator: "\n\n")
        }

        if let item = formattedItems.first {
            let lines = item.components(separatedBy: .newlines)

            if lines.count > 1 {
                return Array(lines.dropFirst()).joined(separator: "\n")
            }
        }

        return nil
    }
    
    private func parsedPlaceFromActionData() -> (title: String, latitude: Double, longitude: Double)? {
        guard let actionData = analysisRecord?.actionData else {
            return nil
        }

        let lines = actionData
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        let title = lines.first ?? "위치"

        guard
            let latitudeLine = lines.first(where: { $0.hasPrefix("latitude:") }),
            let longitudeLine = lines.first(where: { $0.hasPrefix("longitude:") }),
            let latitude = Double(latitudeLine.replacingOccurrences(of: "latitude:", with: "")),
            let longitude = Double(longitudeLine.replacingOccurrences(of: "longitude:", with: ""))
        else {
            return nil
        }

        return (title, latitude, longitude)
    }
    
    private func formattedBodyLine(_ line: String) -> String {
        // ISO 날짜 문자열이면 날짜만 남김
        if line.contains("T") {
            return String(line.prefix(10))
        }

        return line
    }

    private func formattedScheduleBody(from lines: [String]) -> String? {
        let dateLines = lines
            .filter { $0.contains("T") }
            .map { String($0.prefix(10)) }

        if dateLines.count >= 2 {
            return "\(dateLines[0]) ~ \(dateLines[1])"
        }

        if dateLines.count == 1 {
            return dateLines[0]
        }

        return nil
    }
}

struct AppleMapView: View {
    let latitude: Double
    let longitude: Double
    let title: String

    var body: some View {
        Map(
            initialPosition: .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: latitude,
                        longitude: longitude
                    ),
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.01,
                        longitudeDelta: 0.01
                    )
                )
            )
        ) {
            Marker(
                title,
                coordinate: CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude
                )
            )
        }
    }
}
