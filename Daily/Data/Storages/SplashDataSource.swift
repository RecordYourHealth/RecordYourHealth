//
//  SplashDataSource.swift
//  Daily
//
//  Created by seungyooooong on 10/21/24.
//

import Foundation

final class SplashDataSource {
    static let shared = SplashDataSource()
    private init() { }
    
    // TODO: 추후 수정
    func getCatchPhrase() -> String {
        if UserDefaultManager.language == Languages.korean.rawValue {
            return "여러분의 '매일'을 설계하고 🎨\n\n\t\t, 기록하고 📝, 확인해보세요 👏"
        } else {
            return "Design 🎨, Record 📝\n\n\t\t, and Check 👏 'Daily'!!"
        }
    }
    
    func checkNotice() -> Bool {
        return Date() < "2025-01-15".toDate()!  // TODO: 추후 수정
    }
    
    func loadApp(_ isWait: Bool = false) async -> Bool {
        if isWait { try? await Task.sleep(nanoseconds: 2_100_000_000) }
        return true
    }
}
