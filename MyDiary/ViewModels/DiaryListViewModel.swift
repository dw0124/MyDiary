//
//  DiaryListViewModel.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/11.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class DiaryListViewModel {
    
    var diaryList: Observable<[DiaryItem]> = Observable([])
    
    /// 일기 목록 불러오는 메소드
    func getDiaryListData() {
        let ref = Database.database().reference()
        guard let currentUser = Auth.auth().currentUser else { return }
        
        ref.child("users/\(currentUser.uid)/memos").observeSingleEvent(of: .value) { snapshot in
            guard let snapData = snapshot.value as? [String : Any] else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: Array(snapData.values), options: []) else { return }
            do {
                let diaryList = try JSONDecoder().decode([DiaryItem].self, from: data).sorted { $0.createTime > $1.createTime }
                self.diaryList.value = diaryList
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
