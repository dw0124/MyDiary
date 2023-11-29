//
//  ExUIImage.swift
//  MyDiary
//
//  Created by 김두원 on 2023/11/01.
//

import Foundation
import UIKit

extension UIImage {
    // UIGraphicsImageRenderer
    static func resize(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale

        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return renderImage
    }
}
