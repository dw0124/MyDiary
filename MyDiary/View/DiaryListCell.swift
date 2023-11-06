//
//  DiaryListCell.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/12.
//

import UIKit
import Foundation
import SnapKit

class DiaryListCell: UICollectionViewCell {
    static let identifier = "diaryListCell"
    
    // 이미지를 표시할 이미지 뷰
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let dividerLine: UIView = {
        let dividerLine = UIView()
        dividerLine.backgroundColor = .lightGray
        return dividerLine
    }()
    
    // 초기화 및 레이아웃 설정
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dividerLine)
        
        imageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(imageView.snp.height)
        }
        
        timeLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(12)
            $0.top.equalTo(imageView.snp.top).offset(4)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(timeLabel.snp.leading)
            $0.top.equalTo(timeLabel.snp.bottom).offset(4)
        }
        
        dividerLine.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    func configure(with diaryItem: DiaryItem) {
        
        // 이미지 처리
        if let previewImageUrl = diaryItem.imageURL?.first {
            ImageCacheManager.shared.loadImageFromStorage(storagePath: previewImageUrl) { image in
                DispatchQueue.main.async {
                    if let image = image {
                        let resizedImage = UIImage.resize(image: image, newWidth: self.imageView.frame.width)
                        self.imageView.image = resizedImage
                    }
                }
            }
        } else {
            imageView.image = nil
        }
        
        // 날짜 - "yyyyMMddHHmmss"형식으로 된 문자열을 "yyyy년 MM월 dd일"으로 변경
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"

        if let date = dateFormatter.date(from: diaryItem.createTime) {
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            let formattedDateString = dateFormatter.string(from: date)
            timeLabel.text = formattedDateString
        } else {
            timeLabel.text = ""
        }
        
        // 제목
        titleLabel.text = diaryItem.title
    }

}
