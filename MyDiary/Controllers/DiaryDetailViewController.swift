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
    
    let diaryDetailVM = DiaryDetailViewModel()
    
    let scrollView = UIScrollView()
    
    var colleciontView: UICollectionView!
    var dateLabel = UILabel()
    var titleLabel = UILabel()
    var contentLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        setBinding()
    }
    
    private func setBinding() {
        diaryDetailVM.diaryList.bind { diaryItem in
            self.colleciontView.reloadData()
            self.dateLabel.text = diaryItem?.createTime
            self.titleLabel.text = diaryItem?.title
            self.contentLabel.text = diaryItem?.content
        }
    }
}

// MARK: - UI 관련
extension DiaryDetailViewController {
    private func setupUI() {
        view.backgroundColor = .white
        
        // 네비게이션 오른쪽 버튼
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: nil)
        let ok = UIAction(title: "수정",image: UIImage(systemName: "square.and.pencil"), handler: { _ in print("확인") })
        let cancel = UIAction(title: "삭제", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { _ in print("삭제") })
        let buttonMenu = UIMenu(children: [ok, cancel])
        rightButton.menu = buttonMenu
        self.navigationItem.rightBarButtonItem = rightButton
        
        // scrollView
        scrollView.showsVerticalScrollIndicator = false
        
        // collectionView
        colleciontView = {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0.0
            let itemWidth = UIScreen.main.bounds.width// * 0.85
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
        
        // dateLabel
        dateLabel = {
            let label = UILabel()
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .justified
            label.numberOfLines = 0
            return label
        }()
        
        // titelLabel
        titleLabel = {
            let label = UILabel()
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 24)
            label.textAlignment = .justified
            label.numberOfLines = 0
            return label
        }()
        
        // contentLabel
        contentLabel = {
            let label = UILabel()
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 16)
            label.textAlignment = .justified
            label.numberOfLines = 0
            return label
        }()
        
        colleciontView.dataSource = self
        colleciontView.delegate = self
        colleciontView.prefetchDataSource = self
    }

    private func setupLayout() {
        scrollView.addSubview(colleciontView)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(contentLabel)
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints {
            //$0.top.equalTo(colleciontView.snp.bottom).inset(16)
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        if diaryDetailVM.diaryList.value?.imageURL == nil {
            colleciontView.snp.makeConstraints {
                $0.top.equalTo(scrollView)
                $0.width.equalToSuperview()//.multipliedBy(0.85)
                $0.height.equalTo(0)
                $0.centerX.equalToSuperview()
            }
        } else {
            colleciontView.snp.makeConstraints {
                $0.top.equalTo(scrollView)
                $0.width.equalToSuperview()//.multipliedBy(0.85)
                $0.height.equalTo(colleciontView.snp.width)
                $0.centerX.equalToSuperview()
            }
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(colleciontView.snp.bottom).offset(16)
            $0.width.equalToSuperview().multipliedBy(0.95)
            $0.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom)
            $0.width.equalToSuperview().multipliedBy(0.95)
            $0.centerX.equalToSuperview()
        }

        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.width.equalToSuperview().multipliedBy(0.95)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DiaryDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryDetailVM.diaryList.value?.imageURL?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryDetailImageCell.identifier, for: indexPath) as? DiaryDetailImageCell else { return UICollectionViewCell() }
    
        if cell.imageView.image == nil {
            if let imageURL = diaryDetailVM.diaryList.value?.imageURL?[indexPath.item] {
                ImageCacheManager.shared.loadImageFromStorage(storagePath: imageURL) { image in
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                }
            } else {
                cell.imageView.image = nil
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension DiaryDetailViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let imageURL = diaryDetailVM.diaryList.value?.imageURL?[indexPath.item]  {
                ImageCacheManager.shared.loadImageFromStorage(storagePath: imageURL) { image in }
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension DiaryDetailViewController: UICollectionViewDelegate {
    
}
