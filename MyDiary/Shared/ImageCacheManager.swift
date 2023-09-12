//
//  ImageCacheManager.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/12.
//

import UIKit
import Foundation

class ImageCacheManager {
    
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    
    func loadImage(_ imageUrlString: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: imageUrlString)
        
        if let cachedImage = ImageCacheManager.shared.cache.object(forKey: cacheKey) {
            completion(cachedImage)
            return
        }
        if let url = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    ImageCacheManager.shared.cache.setObject(image, forKey: cacheKey)
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
