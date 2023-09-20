//
//  ImageCacheManager.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/12.
//

import UIKit
import Foundation
import FirebaseStorage

class ImageCacheManager {
    
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    /// firebase storage에서 이미지 데이터 불러오는 메소드
    func loadImageFromStorage(storagePath: String, completion: @escaping (UIImage?) -> Void) {
        // Firebase Storage에 저장된 이미지를 저장하지 않았을때
        if storagePath == "" {
            completion(nil)
            return
        }
        
        let cacheKey = NSString(string: storagePath)
        
        // 캐시에 저장된 이미지가 있을때
        if let cachedImage = ImageCacheManager.shared.cache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        } else { // 캐시에 저장된 이미지가 없을때 Firebase Storage에서 이미지를 불러오고 캐시로 저장
            let storage = Storage.storage()
            let storageRef = storage.reference(forURL: storagePath)
            storageRef.getData(maxSize: Int64(100 * 1024 * 1024)){ (data, error) in
                if let error = error {
                    print("Error Occured in getting image : \(error)")
                }
                else {
                    if let data = data , let image = UIImage(data: data) {
                        ImageCacheManager.shared.cache.setObject(image, forKey: cacheKey)
                        completion(image)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
}
