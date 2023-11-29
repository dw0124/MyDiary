//
//  FeedTableViewCell.swift
//  MyDiary
//
//  Created by 김두원 on 2023/11/09.
//

import UIKit
import SnapKit

class DiaryListImageTableViewCell: UITableViewCell {

    static let identifier = "diaryListImageTableViewCell"
    
    var diaryItem: DiaryItem? = nil
    
    var deleteDiaryItemHandelr: (() -> Void)?
    var editDiaryItemHandelr: (() -> Void)?
    
    var stackView = UIStackView()
    
    let labelInset: CGFloat = 24
    
    var dateLabel = UILabel()
    var titleLabel = UILabel()
    var contentLabel = UILabel()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let itemWidth = UIScreen.main.bounds.width - labelInset
        let itemHeight: CGFloat = itemWidth
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.backgroundView?.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true // 페이징 활성화
        collectionView.register(DiaryListImageCell.self, forCellWithReuseIdentifier: DiaryListImageCell.identifier)
        return collectionView
    }()
    var pageControl = UIPageControl()
    
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
        
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        
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
    
    // setup UI + Layout
    private func setupCell() {
        
        selectionStyle = .none
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        
        dateLabel = {
            let label = UILabel()
            label.tintColor = .lightGray
            label.font = UIFont.systemFont(ofSize: 10)
            return label
        }()
        
        titleLabel = {
            let label = UILabel()
            label.tintColor = .black
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            
            return label
        }()
        
        contentLabel = {
            let label = UILabel()
            label.tintColor = .lightGray
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
        
        let imageStackView = UIStackView()
        imageStackView.axis = .vertical
        imageStackView.spacing = 0
        
        // pageControl
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = 3// 페이지 수를 설정하세요 (예: 3)
        pageControl.currentPage = 0 // 현재 페이지를 설정하세요 (예: 0)

        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.layoutMargins = UIEdgeInsets(top: 6, left: labelInset/2, bottom: 6, right: labelInset/2)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        //dateTitleStackView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        dateTitleStackView.addArrangedSubview(dateLabel)
        dateTitleStackView.addArrangedSubview(titleLabel)
        
        buttonStackView.addArrangedSubview(dateTitleStackView)
        buttonStackView.addArrangedSubview(rightButton)
        
        imageStackView.addArrangedSubview(collectionView)
        imageStackView.addArrangedSubview(pageControl)
        
        stackView.addArrangedSubview(buttonStackView)
//        stackView.addArrangedSubview(collectionView)
//        stackView.addArrangedSubview(pageControl)
        stackView.addArrangedSubview(imageStackView)
        stackView.addArrangedSubview(contentLabel)
        
        contentView.addSubview(stackView)
        
        stackView.setCustomSpacing(10, after: buttonStackView)
        stackView.setCustomSpacing(10, after: imageStackView)

        stackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        rightButton.imageView?.snp.makeConstraints {
            $0.trailing.equalToSuperview()
        }

        collectionView.snp.makeConstraints {
            $0.width.equalToSuperview().priority(.high)
            $0.height.equalTo(collectionView.snp.width)
            $0.centerX.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
        }

        dateLabel.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(24).priority(.high)
        }
        titleLabel.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(24).priority(.high)
        }
        contentLabel.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(24).priority(.high)
        }
    }
    
    
    // configure
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
        
        pageControl.numberOfPages = diaryItem.imageURL?.count ?? 0
        
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension DiaryListImageTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryItem?.imageURL?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryListImageCell.identifier, for: indexPath) as? DiaryListImageCell else { return UICollectionViewCell() }
        
        if let imageArray = diaryItem?.imageURL {
            let imageURL = imageArray[indexPath.item]
            cell.configure(with: imageURL)
        }
        cell.imageView.backgroundColor = .white
        return cell
    }
    
}

// MARK: - UICollectionViewDataSourcePrefetching
extension DiaryListImageTableViewCell: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(indexPaths)
    }
}

// MARK: - UICollectionViewDelegate
extension DiaryListImageTableViewCell: UICollectionViewDelegate {
    
}

// MARK: - UIScrollViewDelegate / pageControl 관련
extension DiaryListImageTableViewCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
            pageControl.currentPage = currentPage
        }
    }
    
    @objc func pageControlValueChanged(_ sender: UIPageControl) {
        let indexPath = IndexPath(item: sender.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
