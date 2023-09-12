//
//  DiaryList.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/11.
//

import Foundation

struct DiaryItem: Codable {
    let content: String
    let createTime: String
    let imageURL: [String]
    let title: String
}

struct DiaryData: Codable {
    let diaryItems: [String: DiaryItem]
}
