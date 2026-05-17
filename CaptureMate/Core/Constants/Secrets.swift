//
//  Secrets.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import Foundation

enum Secrets {
    static func value(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let value = plist[key] as? String else {
            fatalError("Secrets.plist에서 \(key)를 찾을 수 없습니다.")
        }

        return value
    }
}
