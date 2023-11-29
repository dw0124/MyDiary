//
//  DiaryDetailImageCell.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/19.
//

import UIKit
import Foundation
import SnapKit

class DiaryDetailImageCell: UICollectionViewCell {
    static let identifier = "DiaryDetailImageCell"
    
    // 이미지를 표시할 이미지 뷰
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    // 초기화 및 레이아웃 설정
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    func configure(with imageUrl: String) {
        ImageCacheManager.shared.loadImageFromStorage(storagePath: imageUrl) { image in
            DispatchQueue.main.async {
                if let image = image {
                    let resizedImage = UIImage.resize(image: image, newWidth: self.imageView.frame.width)
                    self.imageView.image = resizedImage
                } else {
                    self.imageView.image = nil
                }
            }
        }
    }
}
