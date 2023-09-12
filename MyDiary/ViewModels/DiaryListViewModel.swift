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
    
    func getDiaryImage(storagePath: String, completion: @escaping (Data) -> Void) {
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
    
    
}
