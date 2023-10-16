//
//  MainViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/03.
//

import UIKit
import Foundation
import SnapKit
import DropDown

class DiaryListViewController: UIViewController {
    
    let diaryListSingleton = DiaryListSingleton.shared
    
    var segmentControl = UISegmentedControl()
    var colleciontView: UICollectionView!
    
    var filterViewCheck = false
    var headerViewHeight = 40.0
    
    var someView = UIView()
    var someViewButton = UIButton()
    
    var filterView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLayout()
        setBinding()
    }
}

extension DiaryListViewController {
    func setBinding() {
        diaryListSingleton.filteredDiaryList.bind { diaryItemArr in
            self.colleciontView.reloadData()
        }
    }
}

// MARK: - UI 관련
extension DiaryListViewController {
    private func setupUI() {
        view.backgroundColor = .white
        
        someView = {
            let view = UIView()
            view.backgroundColor = .blue
            return view
        }()
        
        someViewButton = {
            let button = UIButton()
            button.setTitle("Centered Button", for: .normal)
            button.backgroundColor = .blue
            button.addTarget(self, action: #selector(changeHeaderView), for: .touchUpInside)
            return button
        }()
        
        filterView = {
            let view = UIView()
            view.backgroundColor = .green
            return view
        }()
        
        colleciontView = {
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeImageFlowLayout())
            collectionView.register(DiaryListImageCell.self, forCellWithReuseIdentifier: DiaryListImageCell.identifier)
            collectionView.register(DiaryListCell.self, forCellWithReuseIdentifier: DiaryListCell.identifier)
            //collectionView.register(DiaryListMenuHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DiaryListMenuHeaderView.identifier)
            collectionView.backgroundColor = .white
            return collectionView
        }()
    
        segmentControl = {
            let controller = UISegmentedControl()
            controller.insertSegment(with: UIImage(systemName: "square.grid.3x3"), at: 0, animated: true)
            controller.insertSegment(with: UIImage(systemName: "square.fill.text.grid.1x2"), at: 1, animated: true)
            controller.selectedSegmentIndex = 0
            return controller
        }()
        segmentControl.addTarget(self, action: #selector(changedSegment), for: .valueChanged)
        
        colleciontView.delegate = self
        colleciontView.dataSource = self
    }

    private func setupLayout() {
        view.addSubview(segmentControl)
        view.addSubview(colleciontView)
        view.addSubview(someView)
        view.addSubview(filterView)
        someView.addSubview(someViewButton)
        
        segmentControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        someView.snp.makeConstraints {
            $0.top.equalTo(segmentControl.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        filterView.snp.makeConstraints {
            $0.top.equalTo(someView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }

        colleciontView.snp.makeConstraints {
            $0.top.equalTo(filterView.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }
        
        someViewButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalToSuperview()
            $0.width.equalTo(50)
        }
    }
    
    private func makeImageFlowLayout() -> UICollectionViewFlowLayout {
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
        
        return flowLayout
    }

    private func makeListFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let minimumInteritemSpacing: CGFloat = 0.0
        let minimumLineSpacing: CGFloat = 0.0
        let numberOfItemPerRow: CGFloat = 1.0
        let itemWidth = (UIScreen.main.bounds.width - ((numberOfItemPerRow - 1) * minimumInteritemSpacing)) / numberOfItemPerRow
        let itemHeight: CGFloat = 80
        
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        flowLayout.minimumLineSpacing = minimumLineSpacing // 아이템 사이의 수직 간격
        flowLayout.minimumInteritemSpacing = minimumInteritemSpacing // 아이템 사이의 수평 간격
        
        return flowLayout
    }

    @objc private func changedSegment(_ sender: UISegmentedControl) {
        
        var selectedFlowLayout = UICollectionViewFlowLayout()
        
        switch sender.selectedSegmentIndex {
        case 0:
            selectedFlowLayout = makeImageFlowLayout()
        case 1:
            selectedFlowLayout = makeListFlowLayout()
        default:
            selectedFlowLayout = makeImageFlowLayout()
        }
        
        colleciontView.reloadData()
        colleciontView.setCollectionViewLayout(selectedFlowLayout, animated: false)
        colleciontView.collectionViewLayout.invalidateLayout()
    }
    
    @objc private func changeHeaderView() {
        print(#function, filterViewCheck)
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyyMMdd"
//
//        if let startDate = dateFormatter.date(from: "20231001"), let endDate = dateFormatter.date(from: "20231012") {
//            diaryListSingleton.startDate = startDate
//            diaryListSingleton.endDate = endDate
//        }
//
//        diaryListSingleton.sortDesending = true
//
//        diaryListSingleton.filterAndSort(diaryList: diaryListSingleton.filteredDiaryList.value!)
        
        if filterViewCheck == false {
            self.filterView.snp.updateConstraints {
                $0.height.equalTo(100)
            }
            filterViewCheck = true
        } else {
            self.filterView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
            filterViewCheck = false
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DiaryListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryListSingleton.filteredDiaryList.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let diaryList = diaryListSingleton.filteredDiaryList.value else { return UICollectionViewCell() }
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            guard let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryListImageCell.identifier, for: indexPath) as? DiaryListImageCell else { return UICollectionViewCell() }
            imageCell.configure(with: diaryList[indexPath.item])
            return imageCell
        case 1:
            guard let listCell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryListCell.identifier, for: indexPath) as? DiaryListCell else { return UICollectionViewCell() }
            listCell.configure(with: diaryList[indexPath.item])
            return listCell
        default:
            guard let listCell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryListCell.identifier, for: indexPath) as? DiaryListCell else { return UICollectionViewCell() }
            listCell.configure(with: diaryList[indexPath.item])
            return listCell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension DiaryListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let diaryDetailVC = DiaryDetailViewController()
        diaryDetailVC.diaryDetailVM.diaryList.value = diaryListSingleton.filteredDiaryList.value?[indexPath.item]
        navigationController?.pushViewController(diaryDetailVC, animated: true)
    }
}

