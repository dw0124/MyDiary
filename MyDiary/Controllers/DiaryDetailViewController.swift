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
        collectionView.register(DiaryListCell.self, forCellWithReuseIdentifier: DiaryListCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = .fast

        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        
        colleciontView.dataSource = self
        colleciontView.delegate = self
        
        view.addSubview(colleciontView)
        
        colleciontView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(colleciontView.snp.width).multipliedBy(1.0/1.0)
        }
        
        setBinding()
    }
    
    private func setBinding() {
        diaryDetailVM.diaryList.bind { diaryItem in
            self.colleciontView.reloadData()
        }
    }
}

extension DiaryDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryDetailVM.diaryList.value?.imageURL.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryListCell.identifier, for: indexPath) as? DiaryListCell else {
            return UICollectionViewCell() }
    
        if let imageURL = diaryDetailVM.diaryList.value?.imageURL[indexPath.item] {
            diaryDetailVM.getDiaryImage(storagePath: imageURL) { data in
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: data)
                }
            }
        } else {
            cell.imageView.image = nil
        }
        
        return cell
    }
}

extension DiaryDetailViewController: UICollectionViewDelegate {
 
}
