//
//  DiaryListMenuHeaderView.swift
//  MyDiary
//
//  Created by 김두원 on 2023/10/06.
//

import UIKit
import Foundation
import SnapKit

class DiaryListMenuHeaderView: UICollectionReusableView {
    static let identifier = "diaryListMenuHeaderView"
    
    var checkView = false
    
    lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        return label
    }()
    
    let myButton: UIButton = {
        let button = UIButton()
        button.setTitle("나의 버튼", for: .normal)
        button.backgroundColor = UIColor.blue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 8.0 // 버튼 둥글게 만들기
        //button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .blue
        
        addSubview(mainLabel)
        addSubview(myButton)
        
        mainLabel.snp.makeConstraints { label in
            label.trailing.equalToSuperview()
            label.centerY.equalToSuperview()
            label.height.equalTo(40)
        }
        
        myButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(40)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.prepare(text: nil)
    }
    
    func prepare(text: String?) {
        self.mainLabel.text = text
    }
    
    @objc private func buttonTapped() {
        if checkView == false {
            let newHeight: CGFloat = 200.0
            frame.size.height = newHeight
            checkView = true
        } else {
            let newHeight: CGFloat = 100.0
            frame.size.height = newHeight
            checkView = false
        }
    }
}
