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
    
    //var categoryList: Observable<[String]> = Observable(["카테고리 없음"])
    
    var categoryList: Observable<[CategoryItem]> = Observable([CategoryItem(key: "0", category: "카테고리 없음")])
    
    func getCategoryList() {
        print(#function)
        let ref = Database.database().reference()
        guard let currentUser = Auth.auth().currentUser else { return }
        
        ref.child("users/\(currentUser.uid)/categoryList").observeSingleEvent(of: .value) { (snapshot, str) in
            guard let snapData = snapshot.value as? [String : String] else { return }
            snapData.forEach { (key, value) in
                self.categoryList.value?.append(CategoryItem(key: key, category: value))
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
                //self.categoryList.value?.append(category)
                self.categoryList.value?.append(CategoryItem(key: createTime, category: category))
            }
        }
    }
    
    func deleteCategory(_ index: Int) {
        let ref = Database.database().reference()
        guard let currentUser = Auth.auth().currentUser else { return }
        
        // 삭제할 카테고리의 키
        guard let key = categoryList.value?[index].key else { return }
        
        // 값으로 nil을 저장하면 데이터 삭제
        let data: [String: Any?] = [key: nil]
        
        // Realtime Database에 저장
        ref.child("users").child(currentUser.uid).child("categoryList").updateChildValues(data as [AnyHashable : Any]) { error,_ in
            if let error = error {
                print(error.localizedDescription, "카테고리 삭제중 오류가 발생하였습니다.")
            } else {
                // 현재 목록에서 삭제
                self.categoryList.value?.remove(at: index)
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
