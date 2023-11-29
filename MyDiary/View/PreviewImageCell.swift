//
//  PreviewImagesCell.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/07.
//

import UIKit
import Foundation
import SnapKit

class PreviewImageCell: UICollectionViewCell {
    static let identifier = "PreviewImageCell"
    
    // 이미지를 표시할 이미지 뷰
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white
        return imageView
    }()
    
    // 삭제 버튼을 표시할 버튼
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        button.tintColor = .red
        
        return button
    }()
    
    // 초기화 및 레이아웃 설정
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
        
        imageView.snp.makeConstraints { make in
            //make.edges.equalToSuperview()
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
//            make.centerY.equalTo(imageView.snp.top)
//            make.centerX.equalTo(imageView.snp.trailing)
            make.top.equalToSuperview().offset(-6)
            make.trailing.equalToSuperview().offset(6)
            make.width.height.equalTo(16) // 적절한 크기 조절
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
