//
//  CategorySingleton.swift
//  MyDiary
//
//  Created by 김두원 on 2023/10/17.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class CategorySingleton {
    
    private init() { getCategoryList() }
    
    static let shared = CategorySingleton()
    
    var categoryList: Observable<[String]> = Observable(["카테고리 없음"])
    
    func getCategoryList() {
        print(#function)
        let ref = Database.database().reference()
        guard let currentUser = Auth.auth().currentUser else { return }
        
        ref.child("users/\(currentUser.uid)/categoryList").observeSingleEvent(of: .value) { snapshot,str  in
            guard let snapData = snapshot.value as? [String : Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: Array(snapData.values), options: []) else { return }
            do {
                let categoryList = try JSONDecoder().decode([String].self, from: data)
                self.categoryList.value?.append(contentsOf: categoryList)
                // = categoryList
            } catch let error {
                print("\(error.localizedDescription)")
            }
        }
    }
    
    func addCategory(_ category: String) {
        let createTime = generateUniqueKey()
        let ref = Database.database().reference()
        guard let currentUser = Auth.auth().currentUser else { return }
        
        // Realtime Database에 저장될 데이터 [key: value]
        let data: [String: String] = [createTime: category]
        
        // Realtime Database에 저장
        ref.child("users").child(currentUser.uid).child("categoryList").updateChildValues(data) { (error, ref) in
            if let error = error as? NSError {
                print("카테고리 저장 오류: \(error.localizedDescription)")
            } else {
                self.categoryList.value?.append(category)
            }
        }
    }
    
    /// 날짜와 시간을 합쳐서 유일키로 만들기 위한 메소드
    func generateUniqueKey() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss" // 날짜 및 시간 형식 설정
        
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate) // 현재 날짜 및 시간을 문자열로 변환
        
        return dateString
    }
}
