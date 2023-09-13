//
//  DiaryDetailViewModel.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/13.
//

import Foundation
import FirebaseStorage

class DiaryDetailViewModel {
    
    var diaryList: Observable<DiaryItem> = Observable(nil)
    
    /// firebase storage에서 이미지 데이터 불러오는 메소드
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
