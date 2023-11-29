//
//  DropDownButton.swift
//  MyDiary
//
//  Created by 김두원 on 2023/10/16.
//

import UIKit
import SnapKit

class DropDownButton: UIButton {
    
    let label = UILabel()
    let myImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 버튼 속성 설정
        self.backgroundColor = UIColor.green // 버튼의 배경색
        self.setTitleColor(UIColor.white, for: .normal) // 버튼 텍스트 색상
        self.layer.cornerRadius = 8 // 버튼의 모서리를 둥글게
        
        // Label 설정
        label.textAlignment = .left
        label.textColor = UIColor.black
        label.text = "카테고리 없음"
        label.tintColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(label)
        
        // ImageView 설정
        myImageView.contentMode = .scaleAspectFit
        myImageView.image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate) // 이미지 이름 설정
        
        myImageView.tintColor = .gray
        self.addSubview(myImageView)
        
        // SnapKit을 사용하여 레이아웃 설정
        label.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(8) // Label 왼쪽 여백
            make.centerY.equalTo(self) // Label 수직 중앙 정렬
        }
        
        myImageView.snp.makeConstraints { make in
            make.leading.equalTo(label.snp.trailing).offset(8) // ImageView 왼쪽 여백
            make.trailing.equalTo(self).offset(-8) // ImageView 오른쪽 여백
            make.width.equalTo(24) // ImageView 너비 고정
            make.height.equalTo(24) // ImageView 높이 고정
            make.centerY.equalTo(self) // ImageView 수직 중앙 정렬
        }
        
        
        setupImages()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupImages() {
        if state == .normal {
            myImageView.image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysTemplate)
        } else {
            myImageView.image = UIImage(systemName: "chevron.up")?.withRenderingMode(.alwaysTemplate)
        }
    }
}
