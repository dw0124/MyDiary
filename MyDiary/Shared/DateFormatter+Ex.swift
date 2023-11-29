//
//  DateFormatter+Ex.swift
//  MyDiary
//
//  Created by 김두원 on 2023/11/08.
//

import Foundation

extension DateFormatter {
    static let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        // 다른 원하는 설정을 추가할 수 있습니다.
        return formatter
    }()
    
    static func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }
    
    static func stringToDate(str: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.date(from: str)
    }
}
