//
//  AddMemoViewModels.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/06.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AddMemoViewModel {
    
    var images: Observable<[UIImage]> = Observable([])
    var title: String = ""
    var content: String = ""
    
    /// Firebase Realtime DB에 일기 저장하는 메소드 / completion: 성공 여부, 메시지를 전달
    func saveMemo(completion: @escaping (Bool, String) -> Void) {
        var message = ""
        
        saveImageToStorage { imageUrlArray in
            let databaseRef = Database.database().reference()
            guard let currentUser = Auth.auth().currentUser else {
                return
            }
            let createTime = self.generateUniqueKey()
            let memoData: [String: Any] = ["createTime": createTime, "imageURL": imageUrlArray, "title": self.title, "content": self.content]
            // Realtime Database에 저장
            databaseRef.child("users").child(currentUser.uid).child("memos").child(createTime).setValue(memoData) { (error, ref) in
                if let error = error as? NSError {
                    
                    print("메모 데이터 저장 오류: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                } else {
                    print("메모 데이터 저장 성공")
                    message = "저장을 완료했습니다."
                    completion(true, message)
                }
            }
        }
    }
    
    /// Firebase Storage에 이미지를 저장하는 메소드 / completion: 이미지 경로를 배열에 담아서 전달
    func saveImageToStorage(completion: @escaping ([String]) -> Void) {
        // Firebase Storage 참조 가져오기
        var imageUrlArray: [String] = []
        let storageRef = Storage.storage().reference()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        if let imageArray = images.value {
            for (index, _) in imageArray.enumerated() {
                let imageRef = storageRef.child("images/\(currentUser.uid)/\(UUID().uuidString)_\(index).jpg")
                if let imageData = images.value?[0].jpegData(compressionQuality: 0.9) {
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                        if let error = error {
                            // 업로드 중 오류가 발생한 경우 처리
                            print("이미지 업로드 오류: \(error.localizedDescription)")
                        } else {
                            // 업로드가 성공한 경우 처리
                            print("이미지 업로드 성공")
                            imageUrlArray.append("\(imageRef)")
                            
                            if imageUrlArray.count == imageArray.count {
                                completion(imageUrlArray)
                            }
                        }
                    }
                }
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
