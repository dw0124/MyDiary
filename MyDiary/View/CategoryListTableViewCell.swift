//
//  CategoryListCell.swift
//  MyDiary
//
//  Created by 김두원 on 2023/10/19.
//

import Foundation
import UIKit

class CategoryListTableViewCell: UITableViewCell {
    
    static let identifier = "categoryListTableViewCell"
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .black
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.setImage(UIImage(systemName: "circle.fill"), for: .highlighted)
        return button
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        stackView.addArrangedSubview(categoryLabel)
        stackView.addArrangedSubview(deleteButton)
        contentView.addSubview(stackView)
        
        categoryLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.equalToSuperview()
            $0.width.equalTo(deleteButton.snp.height)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.bottom.equalToSuperview().inset(8)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        //contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
