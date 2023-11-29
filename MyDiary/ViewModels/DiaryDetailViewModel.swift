//
//  DiaryDetailViewModel.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/13.
//

import Foundation
import FirebaseStorage

class DiaryDetailViewModel {
    
    var diaryItem: Observable<DiaryItem> = Observable(nil)
    var diaryListIndex: Int?
//    var createTime = ""
//    var title = "제목"
//    var content = "내용"
//    var imageURL = [String]()
    
//    init(diaryItem: DiaryItem) {
//        let inputDateString = diaryItem.createTime // yyyyMMDDhhmmss 형식의 입력 문자열
//
//        let inputDateFormatter = DateFormatter()
//        inputDateFormatter.dateFormat = "yyyyMMddHHmmss" // 입력 문자열 형식 설정
//
//        if let date = inputDateFormatter.date(from: inputDateString) {
//            let outputDateFormatter = DateFormatter()
//            outputDateFormatter.dateFormat = "yyyy년 MM월 dd일" // 출력 문자열 형식 설정
//            let outputDateString = outputDateFormatter.string(from: date)
//
//            createTime = outputDateString // "2023년 12월 25일"
//        } else {
//            print("날짜 변환 실패")
//        }
//
//        title = diaryItem.title ?? "제목 없음"
//        content = diaryItem.content ?? "내용 없음"
//        imageURL = diaryItem.imageURL ?? []
//    }
}
