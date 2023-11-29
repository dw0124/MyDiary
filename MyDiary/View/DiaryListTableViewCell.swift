//
//  DiaryListTableViewCell.swift
//  MyDiary
//
//  Created by 김두원 on 2023/11/13.
//


import UIKit
import SnapKit

class DiaryListTableViewCell: UITableViewCell {

    static let identifier = "diaryListTableViewCell"
    
    var deleteDiaryItemHandelr: (() -> Void)?
    var editDiaryItemHandelr: (() -> Void)?
    
    var diaryItem: DiaryItem? = nil
    
    let stackView = UIStackView()
    
    let labelInset: CGFloat = 24
    var dateLabel = UILabel()
    var titleLabel = UILabel()
    var contentLabel = UILabel()
    
    var diaryImageView = UIImageView()
    
    lazy var rightButton: UIButton = {
        let rightButton = UIButton()
        rightButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        let edit = UIAction(
            title: "수정",
            image: UIImage(systemName: "square.and.pencil"),
            handler: { [weak self] _ in
                guard let editDiaryItemHandelr = self?.editDiaryItemHandelr else { return }
                editDiaryItemHandelr()
            }
        )
        let delete = UIAction(
            title: "삭제", image: UIImage(systemName: "trash"),
            attributes: .destructive,
            handler: { [weak self] _ in
                guard let deleteDiaryItemHandelr = self?.deleteDiaryItemHandelr else { return }
                deleteDiaryItemHandelr()
            }
        )
        let buttonMenu = UIMenu(children: [edit, delete])
        rightButton.menu = buttonMenu
        rightButton.tintColor = .black
        rightButton.showsMenuAsPrimaryAction = true
        return rightButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = #colorLiteral(red: 0.9239165187, green: 0.9213962555, blue: 0.9468390346, alpha: 1)
        contentView.backgroundColor = .white
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let diaryItem = diaryItem {
            configure(diaryItem)
        }
    }
    
    private func setupCell() {
        
        selectionStyle = .none
        
        dateLabel = {
            let label = UILabel()
            label.text = "0000년 00월 00일"
            label.tintColor = .lightGray
            label.font = UIFont.systemFont(ofSize: 10)
            return label
        }()
        
        titleLabel = {
            let label = UILabel()
            label.tintColor = .black
            label.text = "제목"
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            
            return label
        }()
        
        contentLabel = {
            let label = UILabel()
            label.tintColor = .lightGray
            label.text = "내용"
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 3
            return label
        }()

        // dateLabel과 feedTitleLabel을 수직으로 담음
        let dateTitleStackView = UIStackView()
        dateTitleStackView.axis = .vertical
        dateTitleStackView.spacing = 0

        // 1번 stackView와 button을 수평으로 담음
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .fill
        buttonStackView.spacing = 8
        
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 6, left: labelInset/2, bottom: 12, right: labelInset/2)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        stackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        stackView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        dateTitleStackView.addArrangedSubview(dateLabel)
        dateTitleStackView.addArrangedSubview(titleLabel)
        
        buttonStackView.addArrangedSubview(dateTitleStackView)
        buttonStackView.addArrangedSubview(rightButton)
        
        stackView.addArrangedSubview(buttonStackView)
        stackView.addArrangedSubview(contentLabel)
        
        contentView.addSubview(stackView)
        
        stackView.setCustomSpacing(10, after: buttonStackView)
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        rightButton.imageView?.snp.makeConstraints {
            $0.trailing.equalToSuperview()
        }
        
        dateTitleStackView.setContentCompressionResistancePriority(.required, for: .vertical)

        dateLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        contentLabel.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(24).priority(.high)
        }
    }
    
    func configure(_ diaryItem: DiaryItem) {
        
        self.diaryItem = diaryItem
        
        // 날짜 - "yyyyMMddHHmmss"형식으로 된 문자열을 "yyyy년 MM월 dd일"으로 변경
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"

        if let date = dateFormatter.date(from: diaryItem.createTime) {
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            let formattedDateString = dateFormatter.string(from: date)
            dateLabel.text = formattedDateString
        } else {
            dateLabel.text = ""
        }
        
        titleLabel.text = diaryItem.title
        contentLabel.text = diaryItem.content
    }
}
