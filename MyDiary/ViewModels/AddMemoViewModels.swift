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
    
    func saveMemo() {
        saveImageToStorage { imageUrlArray in
            print("#1")
            let databaseRef = Database.database().reference()
            guard let currentUser = Auth.auth().currentUser else {
                print("#2")
                return
            }
            let memoData: [String: Any] = ["imageURL": imageUrlArray, "title": self.title, "content": self.content]
            print("#3")
            // Realtime Database에 저장
            databaseRef.child("users").child(currentUser.uid).child("memos").child(self.generateUniqueKey()).setValue(memoData) { (error, ref) in
                if let error = error {
                    print("메모 데이터 저장 오류: \(error.localizedDescription)")
                } else {
                    print("메모 데이터 저장 성공")
                }
            }
        }
    }
    
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
            
    func generateUniqueKey() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss" // 날짜 및 시간 형식 설정
        
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate) // 현재 날짜 및 시간을 문자열로 변환
        
        return dateString
    }
}
