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
    
    var diaryItem: DiaryItem?
    
    var address: String = ""
    var lat: Double = 0
    var lng: Double = 0
    var images: Observable<[UIImage]> = Observable([])
    var imagesSorted: Observable<[Int: UIImage]> = Observable([:])
    var title: String = ""
    var content: String = ""
    
    /// Firebase Realtime DB에 일기 저장하는 메소드 / completion: 성공 여부, 메시지를 전달
    func saveMemo(completion: @escaping (Bool, String) -> Void) {
        var message = ""
        
        // 입력된 값이 없으면 ""을 저장
        address = address == "선택된 위치 없음" ? "" : address
        content = content == "내용을 입력하세요" ? "" : content
        
        saveImageToStorage { imageUrlArray in
            
            let imageUrlArr = imageUrlArray ?? [""]
            
            let databaseRef = Database.database().reference()
            guard let currentUser = Auth.auth().currentUser else {
                return
            }
            let createTime = self.generateUniqueKey()
            let memoData: [String: Any] = [
                "createTime": createTime,
                "address": self.address,
                "lat": self.lat,
                "lng": self.lng,
                "imageURL": imageUrlArr,
                "title": self.title,
                "content": self.content
            ]
            // Realtime Database에 저장
            databaseRef.child("users").child(currentUser.uid).child("memos").child(createTime).setValue(memoData) { (error, ref) in
                if let error = error as? NSError {
                    
                    print("메모 데이터 저장 오류: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                } else {
                    print("메모 데이터 저장 성공")
                    message = "저장을 완료했습니다."
                    
                    // alert를 통해서 성공했음을 알리고 DiaryListVC에서 collectionView item으로 추가하기 위함
                    self.diaryItem = DiaryItem(
                        content: self.content,
                        createTime: createTime,
                        imageURL: imageUrlArr,
                        title: self.title,
                        lat: self.lat,
                        lng: self.lng
                    )
                    
                    completion(true, message)
                }
            }
        }
    }
    
    /// Firebase Storage에 이미지를 저장하는 메소드 / completion: 이미지 경로를 배열에 담아서 전달
    func saveImageToStorage(completion: @escaping ([String]?) -> Void) {
        if images.value?.count == 0 {
            completion(nil)
            return
        }
        
        // Firebase Storage 참조 가져오기
        var imageUrlArray: [Int:String] = [:]
        let storageRef = Storage.storage().reference()
        
        guard let currentUser = Auth.auth().currentUser else { return }
        
        if let imageArray = images.value {
            for (index, _) in imageArray.enumerated() {
                let imageRef = storageRef.child("images/\(currentUser.uid)/\(UUID().uuidString)_\(index).jpg")
                if let imageData = imageArray[index].jpegData(compressionQuality: 0.9) {
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    
                    imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                        if let error = error {
                            // 업로드 중 오류가 발생한 경우 처리
                            print("이미지 업로드 오류: \(error.localizedDescription)")
                        } else {
                            // 업로드가 성공한 경우 처리
                            print("이미지 업로드 성공")
                            imageUrlArray.updateValue("\(imageRef)", forKey: index)
                            
                            // index를 순서로 정렬한 배열을 completion으로 전달
                            let sortedImageUrlArray = imageUrlArray.sorted { $0.key < $1.key }.map { $0.value }
                            
                            // 선택된 이미지의 개수와 storage에 저장하는 이미지의 개수가 같은지 확인
                            if imageUrlArray.count == imageArray.count {
                                completion(sortedImageUrlArray)
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
