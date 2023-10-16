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
    
    var filterView = DiaryListFilterView()
    
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
            button.addTarget(self, action: #selector(changeFilterView), for: .touchUpInside)
            return button
        }()
        
        filterView = {
            let view = DiaryListFilterView()
            view.categoryButton.addTarget(self, action: #selector(dropDownCategoryFilter), for: .touchUpInside)
            view.dateSortButton.addTarget(self, action: #selector(dropDownDateSort), for: .touchUpInside)
            view.applyButton.addTarget(self, action: #selector(applyFilter), for: .touchUpInside)
            view.backgroundColor = .white
            view.layer.borderWidth = 1.0
            view.isHidden = true
            return view
        }()
        
        colleciontView = {
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeImageFlowLayout())
            collectionView.register(DiaryListImageCell.self, forCellWithReuseIdentifier: DiaryListImageCell.identifier)
            collectionView.register(DiaryListCell.self, forCellWithReuseIdentifier: DiaryListCell.identifier)
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
            //$0.width.equalTo(50)
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
    
    @objc private func changeFilterView() {
        print(#function, filterViewCheck)
        
        if filterViewCheck == false {
            self.filterView.snp.updateConstraints {
                $0.height.equalTo(168)
            }
        } else {
            self.filterView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
        }
        
        self.filterView.isHidden.toggle()
        self.filterViewCheck.toggle()
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // dropdown 버튼 - 카테고리 선택
    @objc private func dropDownCategoryFilter() {
        let dropDown = DropDown()

        // The view to which the drop down will appear on
        dropDown.anchorView = filterView.categoryButton // UIView or UIBarButtonItem

        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["Car", "Motorcycle", "Truck"]

        // Action triggered on selection
        dropDown.selectionAction = { (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.filterView.categoryButton.label.text = item
        }

        // Will set a custom width instead of the anchor view width
        //dropDownLeft.width = 200
        //dropDown.width = 250

        dropDown.direction = .bottom

        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)

        dropDown.cornerRadius = 15
        
        dropDown.show()
    }
    
    // dropdown버튼 - 날짜 최신, 오래된 순
    @objc private func dropDownDateSort() {
        let dropDown = DropDown()

        // The view to which the drop down will appear on
        dropDown.anchorView = filterView.dateSortButton // UIView or UIBarButtonItem

        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["Car", "Motorcycle", "Truck"]

        // Action triggered on selection
        dropDown.selectionAction = { (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.filterView.dateSortButton.label.text = item
        }

        // Will set a custom width instead of the anchor view width
        //dropDownLeft.width = 200
        //dropDown.width = 250

        dropDown.direction = .bottom

        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)

        dropDown.cornerRadius = 15
        
        dropDown.show()
    }
    
    @objc private func applyFilter() {
        print(#function)
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

