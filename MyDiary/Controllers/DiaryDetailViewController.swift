//
//  DiaryDetailViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/13.
//

import UIKit
import Foundation
import SnapKit

class DiaryDetailViewController: UIViewController {
    
    var diaryDetailVM = DiaryDetailViewModel()

    var scrollView = UIScrollView()
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
        collectionView.register(DiaryDetailImageCell.self, forCellWithReuseIdentifier: DiaryDetailImageCell.identifier)
        return collectionView
    }()
    var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
    
        setupUI()
        setupLayout()
        setBinding()
    }
    
    private func setBinding() {
        diaryDetailVM.diaryItem.bind { diaryItem in
            self.dateLabel.text = diaryItem?.createTime
            self.titleLabel.text = diaryItem?.title
            self.contentLabel.text = diaryItem?.content
            self.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DiaryDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return diaryDetailVM?.diaryList.value?.imageURL?.count ?? 0
        return diaryDetailVM.diaryItem.value?.imageURL?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryDetailImageCell.identifier, for: indexPath) as? DiaryDetailImageCell else { return UICollectionViewCell() }
        
        if let imageURL = diaryDetailVM.diaryItem.value?.imageURL?[indexPath.item] {
            cell.configure(with: imageURL)
        }
        return cell
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension DiaryDetailViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
//            if let imageURL = diaryDetailVM?.diaryList.value?.imageURL?[indexPath.item]  {
            if let imageURL = diaryDetailVM.diaryItem.value?.imageURL?[indexPath.item] {
                ImageCacheManager.shared.loadImageFromStorage(storagePath: imageURL) { image in }
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension DiaryDetailViewController: UICollectionViewDelegate {
    
}

// MARK: - UIScrollViewDelegate / pageControl 관련
extension DiaryDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
            pageControl.currentPage = currentPage
            
            print(scrollView.contentOffset.x / scrollView.frame.size.width)
        }
    }
    
    @objc func pageControlValueChanged(_ sender: UIPageControl) {
        let indexPath = IndexPath(item: sender.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}


// MARK: - UI 관련
extension DiaryDetailViewController {
    private func setupUI() {
        view.backgroundColor = .white

        // 네비게이션 오른쪽 버튼
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: nil)
        let ok = UIAction(
            title: "수정",
            image: UIImage(systemName: "square.and.pencil"),
            handler: {
                [weak self] _ in self?.navigationController?.popViewController(animated: true)
            }
        )
        let cancel = UIAction(
            title: "삭제",
            image: UIImage(systemName: "trash"),
            attributes: .destructive,
            handler: { [weak self] _ in
                print("1234123412341234")
                self?.navigationController?.popViewController(animated: true)
            }
        )
        let buttonMenu = UIMenu(children: [ok, cancel])
        rightButton.menu = buttonMenu
        rightButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = rightButton

        // scrollView
        scrollView.showsVerticalScrollIndicator = false

        // collectionView
        collectionView = {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0.0
            let itemWidth = UIScreen.main.bounds.width - labelInset
            let itemHeight: CGFloat = itemWidth
            flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)

            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
            collectionView.register(DiaryDetailImageCell.self, forCellWithReuseIdentifier: DiaryDetailImageCell.identifier)
            collectionView.backgroundColor = .white
            collectionView.isPagingEnabled = true
            collectionView.decelerationRate = .fast
            collectionView.showsHorizontalScrollIndicator = false
            return collectionView
        }()

        // pageControl
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = diaryDetailVM.diaryItem.value?.imageURL?.count ?? 0 // 페이지 수를 설정하세요 (예: 3)
        pageControl.currentPage = 0 // 현재 페이지를 설정하세요 (예: 0)

        // dateLabel
        dateLabel = {
            let label = UILabel()
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 10)
            label.textAlignment = .justified
            label.numberOfLines = 0
            return label
        }()

        // titelLabel
        titleLabel = {
            let label = UILabel()
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textAlignment = .justified
            label.numberOfLines = 0
            return label
        }()

        // contentLabel
        contentLabel = {
            let label = UILabel()
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 14)
            label.textAlignment = .justified
            label.numberOfLines = 0
            return label
        }()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
    }

    private func setupLayout() {

        view.addSubview(scrollView)

        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: labelInset / 2, bottom: 0, right: labelInset / 2)
        stackView.isLayoutMarginsRelativeArrangement = true

        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(collectionView)
        stackView.addArrangedSubview(pageControl)
        stackView.addArrangedSubview(contentLabel)
        
        stackView.setCustomSpacing(10, after: titleLabel)
        stackView.setCustomSpacing(10, after: pageControl)
        
        stackView.snp.makeConstraints {
            $0.width.equalTo(scrollView)
            $0.top.bottom.equalTo(scrollView)
        }

        collectionView.snp.makeConstraints {
            $0.width.equalToSuperview().priority(.high)
            $0.height.equalTo(collectionView.snp.width)
        }

        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
        }
    }
    
}
