//
//  DiarytListSingleton.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/25.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class DiaryListSingleton {
    
    private init() { getDiaryListData() }
    
    static let shared = DiaryListSingleton()
    
    // 전체 일기 목록
    var diaryList: Observable<[DiaryItem]> = Observable([])
    // 보여주는 일기 목록 - 필터, 정렬을 통해서 변경될 수 있음
    var filteredDiaryList: Observable<[DiaryItem]> = Observable([])
    
    // 필터 + 정렬을 위한 변수
    var filterCheck: Bool = false // 사용자가 필터를 사용했는지 확인
    var category: String? = "카테고리 없음"
    var startDate: Date? = Date()
    var endDate: Date? = Date()
    var sortDesending: Bool? = true
    
    /// 일기 목록 불러오는 메소드
    func getDiaryListData() {
        print(#function)
        let ref = Database.database().reference()
        guard let currentUser = Auth.auth().currentUser else { return }
        
        ref.child("users/\(currentUser.uid)/memos").observeSingleEvent(of: .value) { snapshot in
            guard let snapData = snapshot.value as? [String : Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: Array(snapData.values), options: []) else { return }
            do {
                let diaryList = try JSONDecoder().decode([DiaryItem].self, from: data).sorted { $0.createTime > $1.createTime }
                self.diaryList.value = diaryList
                self.filteredDiaryList.value = diaryList
            } catch let error {
                print("\(error.localizedDescription)")
            }
        }
    }
    
    /// firebase storage에서 이미지 데이터 불러오는 메소드
    func getDiaryImage(storagePath: String, completion: @escaping (Data?) -> Void) {
        if storagePath == "" {
            completion(nil)
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: storagePath)
        storageRef.getData(maxSize: Int64(100 * 1024 * 1024)){ (data, error) in
            if let error = error{
                print("Error Occured in getting image : \(error)")
            }
            else{
                guard let data = data else { return }
                completion(data)
            }
        }
    }
    
    /// firebase realtime DB에서 index에 해당하는 일기를 삭제하는 메소드
    func removeDiaryAtIndex(index: Int) {
        // 데이터 경로를 위한 키 - diary의 createTime이 키
        guard let createTime = diaryList.value?[index].createTime else { return }
        
        // realtime DB에서 데이터 삭제
        let ref = Database.database().reference()
        guard let currentUser = Auth.auth().currentUser else { return }
        ref.child("users/\(currentUser.uid)/memos/\(createTime)").removeValue() { error, result in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        // Storage에서 이미지 삭제
        guard let storagePath = diaryList.value?[index].imageURL else { return }
        storagePath.forEach { imagePath in
            let storage = Storage.storage()
            let storageRef = storage.reference(forURL: imagePath)
            storageRef.delete { error in
              if let error = error {
                  print(error.localizedDescription)
              }
            }
        }
        diaryList.value?.remove(at: index)
    }
}

// MARK: - 필터 + 정렬
extension DiaryListSingleton {
    // 필터 + 정렬하는 메소드
    func filterAndSort() {
        guard var diaryItemArr = diaryList.value else { return }
        
        if let category = category {
            diaryItemArr = filterByCategory(diaryList: diaryItemArr, category)
        }
        if let startDate = startDate, let endDate = endDate {
            diaryItemArr = filterByDateRange(diaryList: diaryItemArr, startDate, endDate)
        }
        if let sortDesending = sortDesending {
            diaryItemArr = sortByDate(diaryList: diaryItemArr, sortDesending)
        }
        
        filteredDiaryList.value = diaryItemArr
        filterCheck = true
    }
    
    // 필터 초기화 - 전체 데이터 보여주기
    func resetFilter() {
        filteredDiaryList.value = diaryList.value
        filterCheck = false
    }
    
    // 카테고리에 해당하는 데이터 필터링
    private func filterByCategory(diaryList: [DiaryItem], _ category: String) -> [DiaryItem] {
        let filteredDiaryList = diaryList.filter { diary in
            return diary.category == category
        }
        
        return filteredDiaryList
    }
    
    // 기간 선택 20xx.xx.xx - 20xx.xx.xx에 해당하는 데이터 필터링
    private func filterByDateRange(diaryList: [DiaryItem], _ start: Date, _ end: Date) -> [DiaryItem] {
        
        var startDate: Date = min(start, end)
        var endDate: Date = max(start, end)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        
        startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
        endDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: endDate)!
        let endDatePlusDay = Calendar.current.date(byAdding: .day, value: 1, to: endDate) ?? endDate
        
        let filteredDiaryList = diaryList.filter { diary in
            guard let createTime = dateFormatter.date(from: diary.createTime) else { return false }
            
            return (startDate..<endDatePlusDay).contains(createTime)
        }
        
        return filteredDiaryList
    }
    
    // 최신순, 오래된 순으로 정렬
    private func sortByDate(diaryList: [DiaryItem], _ desending: Bool) -> [DiaryItem] {
        let sortedDiaryList = diaryList.sorted {
            if desending == true {
                return $0.createTime > $1.createTime
            } else {
                return $0.createTime < $1.createTime
            }
        }
        return sortedDiaryList
    }
    
    // 필터뷰 버튼에 들어갈 문자열
    func makeFilterViewButtonTitle() -> String {
        let startDate = startDate
        let endDate = endDate
        let sortDesending = sortDesending == true ? "최신 순" : "오래된 순"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"

        let startDateString = dateFormatter.string(from: startDate!)
        let endDateString = dateFormatter.string(from: endDate!)
        
        let filterButtonTitle = "\(startDateString) - \(endDateString) / \(sortDesending)"
        
        return filterButtonTitle
    }
}
