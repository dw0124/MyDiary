//
//  MainViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/03.
//

import UIKit
import Foundation
import SnapKit

class DiaryListViewController: UIViewController {
    
    let diaryListSingleton = DiaryListSingleton.shared
    
    let colleciontView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical

        let minimumInteritemSpacing: CGFloat = 3.0
        let minimumLineSpacing: CGFloat = 3.0
        let numberOfItemPerRow: CGFloat = 3.0
        let itemWidth = (UIScreen.main.bounds.width - ((numberOfItemPerRow - 1) * minimumInteritemSpacing)) / numberOfItemPerRow
        let itemHeight: CGFloat = itemWidth

        flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        flowLayout.minimumLineSpacing = minimumLineSpacing // 아이템 사이의 수직 간격
        flowLayout.minimumInteritemSpacing = minimumInteritemSpacing // 아이템 사이의 수평 간격

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(DiaryListCell.self, forCellWithReuseIdentifier: DiaryListCell.identifier)
        collectionView.backgroundColor = .white

        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLayout()
        
        setBinding()
    }
}

extension DiaryListViewController {
    func setBinding() {
        diaryListSingleton.diaryList.bind { diaryItemArr in
            print(#function)
            self.colleciontView.reloadData()
        }
    }
}

// MARK: - UI 관련
extension DiaryListViewController {
    private func setupUI() {
        view.backgroundColor = .white
        
        colleciontView.delegate = self
        colleciontView.dataSource = self
    }

    private func setupLayout() {
        view.addSubview(colleciontView)
        
        colleciontView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DiaryListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryListSingleton.diaryList.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryListCell.identifier, for: indexPath) as? DiaryListCell else {
            return UICollectionViewCell() }
    
        if let previewImageUrl = diaryListSingleton.diaryList.value?[indexPath.item].imageURL?.first {
            ImageCacheManager.shared.loadImageFromStorage(storagePath: previewImageUrl) { image in
                DispatchQueue.main.async {
                    cell.imageView.image = image
                }
            }
        } else {
            cell.imageView.image = nil
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension DiaryListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let diaryDetailVC = DiaryDetailViewController()
        diaryDetailVC.diaryDetailVM.diaryList.value = diaryListSingleton.diaryList.value?[indexPath.item]
        navigationController?.pushViewController(diaryDetailVC, animated: true)
    }
}

