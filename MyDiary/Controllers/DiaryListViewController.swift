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
    
    let diaryListVM = DiaryListViewModel()
    
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
    
    @objc func addDirayList(_ notification: Notification) {
        if let diaryItem = notification.userInfo?["diaryItem"] as? DiaryItem {
            diaryListVM.diaryList.value?.insert(diaryItem, at: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // AddMemoViewController에서 데이터를 추가하면 collectionView로 추가하기 위해서 사용
        NotificationCenter.default.addObserver(self, selector: #selector(addDirayList(_:)), name: Notification.Name("addDiaryItem"), object: nil)
        
        view.backgroundColor = .white
        
        colleciontView.delegate = self
        colleciontView.dataSource = self
        
        view.addSubview(colleciontView)
        
        colleciontView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.bottom.trailing.equalToSuperview()
        }
        
        setBinding()
        
        diaryListVM.getDiaryListData()
    }
    
    func setBinding() {
        diaryListVM.diaryList.bind { diaryItemArr in
            print(#function)
            self.colleciontView.reloadData()
        }
    }
}

extension DiaryListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryListVM.diaryList.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryListCell.identifier, for: indexPath) as? DiaryListCell else {
            return UICollectionViewCell() }
    
        if let previewImageUrl = diaryListVM.diaryList.value?[indexPath.item].imageURL.first {
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

extension DiaryListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let diaryDetailVC = DiaryDetailViewController()
        diaryDetailVC.diaryDetailVM.diaryList.value = diaryListVM.diaryList.value?[indexPath.item]
        navigationController?.pushViewController(diaryDetailVC, animated: true)
    }
}

