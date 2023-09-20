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
    
    let colleciontView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0.0

        let itemWidth = UIScreen.main.bounds.width
        let itemHeight: CGFloat = itemWidth

        flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(DiaryDetailImageCell.self, forCellWithReuseIdentifier: DiaryDetailImageCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = .fast

        return collectionView
    }()
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .justified
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        colleciontView.dataSource = self
        colleciontView.delegate = self
        colleciontView.prefetchDataSource = self
        
        view.addSubview(colleciontView)
        view.addSubview(contentLabel)
        
        colleciontView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(colleciontView.snp.width).multipliedBy(1.0/1.0)
        }
        
        contentLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.top.equalTo(colleciontView.snp.bottom).offset(16)
        }
        
        setBinding()
    }
    
    private func setBinding() {
        diaryDetailVM.diaryList.bind { diaryItem in
            self.colleciontView.reloadData()
            self.contentLabel.text = diaryItem?.content
        }
    }
}

extension DiaryDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryDetailVM.diaryList.value?.imageURL.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryDetailImageCell.identifier, for: indexPath) as? DiaryDetailImageCell else { return UICollectionViewCell() }
    
        if cell.imageView.image == nil {
            if let imageURL = diaryDetailVM.diaryList.value?.imageURL[indexPath.item] {
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

extension DiaryDetailViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let imageURL = diaryDetailVM.diaryList.value?.imageURL[indexPath.item]  {
                ImageCacheManager.shared.loadImageFromStorage(storagePath: imageURL) { image in }
            }
        }
    }
}

extension DiaryDetailViewController: UICollectionViewDelegate {
    
}

extension DiaryDetailViewController {
    //self.navigationController?.navigationItem.leftBarButtonItem
}
