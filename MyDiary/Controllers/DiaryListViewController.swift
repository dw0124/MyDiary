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
    
    var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    // 필터 뷰
    var segmentControl = UISegmentedControl()
    var filterViewCheck = false
    var filterBarView = UIView()
    var filterViewToggleButton = UIButton()
    var filterView = DiaryListFilterView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLayout()
        setBinding()
        
        tableView.refreshControl = refreshControl
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - 바인딩
extension DiaryListViewController {
    func setBinding() {
        // diaryList(전체 리스트)가 변경되면 필터를 실행하고 filterDiaryList의 바인딩이 실행되면서 화면 재구성
        diaryListSingleton.diaryList.bind { dirayList in
            print("diaryList")
            if self.diaryListSingleton.filterCheck == false {
                self.resetFilter()
            } else {
                self.applyFilter()
            }
        }
        diaryListSingleton.filteredDiaryList.bind { filteredDiaryList in
            print("filteredDiaryList")
            self.tableView.reloadData()
        }
    }
}

// MARK: - 필터 관련
extension DiaryListViewController {
    // segementControl 변경시 실행되는 메소드
    @objc private func changedSegment(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    // filterView 줄였다 늘렸다 하는 메소드
    @objc private func changeFilterView() {
        if filterViewCheck == false {
            self.filterView.snp.updateConstraints {
                $0.height.equalTo(168)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.filterView.stackView.isHidden = false
            }
        } else {
            self.filterView.snp.updateConstraints {
                $0.height.equalTo(0)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.filterView.stackView.isHidden = true
                self.view.layoutIfNeeded()
            }
        }
        self.filterViewCheck.toggle()
        self.filterViewToggleButton.isSelected.toggle()
    }
    
    // dropdown 버튼 - 카테고리 선택
    @objc private func dropDownCategoryFilter() {
        let dropDown = DropDown()

        dropDown.anchorView = filterView.categoryButton

        dropDown.dataSource = CategorySingleton.shared.categoryList.value?.map { $0.category } ?? ["카테고리 없음"]

        // Action triggered on selection
        dropDown.selectionAction = { (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.diaryListSingleton.category = item
            self.filterView.categoryButton.label.text = item
        }
        
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.cornerRadius = 15
        
        dropDown.show()
    }
    
    // 필터 - 날짜 선택
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        if sender == filterView.startDatePicker {
            diaryListSingleton.startDate = sender.date
        } else {
            diaryListSingleton.endDate = sender.date
        }
    }
    
    // 필터 - dropdown버튼(날짜 최신, 오래된 순)
    @objc private func dropDownDateSort() {
        let dropDown = DropDown()

        // The view to which the drop down will appear on
        dropDown.anchorView = filterView.dateSortButton // UIView or UIBarButtonItem

        // The list of items to display. Can be changed dynamically
        dropDown.dataSource = ["최신 순", "오래된 순"]

        // Action triggered on selection
        dropDown.selectionAction = { (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.filterView.dateSortButton.label.text = item
            self.diaryListSingleton.sortDesending = index == 0 ? true : false
        }
        dropDown.direction = .bottom

        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)

        dropDown.cornerRadius = 15
        
        dropDown.show()
    }
    
    // 필터 초기화
    @objc private func resetFilter() {
        diaryListSingleton.resetFilter()
        
        self.navigationController?.navigationBar.topItem?.title = "카테고리 없음"
        self.filterViewToggleButton.setTitle("전체 / 최신 순", for: .normal)
    }
    
    // 필터 적용
    @objc private func applyFilter() {
        // 필터 적용
        diaryListSingleton.filterAndSort()
        
        // 네비게이션 타이틀 변경
        self.navigationController?.navigationBar.topItem?.title = diaryListSingleton.category
        
        // 필터뷰 버튼 타이틀 변경
        let filterButtonTitle = diaryListSingleton.makeFilterViewButtonTitle()
        self.filterViewToggleButton.setTitle(filterButtonTitle, for: .normal)
    }
}


// MARK: - UITableViewDataSource
extension DiaryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryListSingleton.filteredDiaryList.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let imageCell = tableView.dequeueReusableCell(withIdentifier: DiaryListImageTableViewCell.identifier, for: indexPath) as! DiaryListImageTableViewCell
        let listCell = tableView.dequeueReusableCell(withIdentifier: DiaryListTableViewCell.identifier, for: indexPath) as! DiaryListTableViewCell
        
        if let diaryList = diaryListSingleton.filteredDiaryList.value {
            
            let diaryItem = diaryList[indexPath.row]
            
            if segmentControl.selectedSegmentIndex == 0 && diaryItem.imageURL != nil {
                // 이미지가 있는 셀 - CollectionView가 있는 셀
                if diaryItem.imageURL != nil {
                    
                    imageCell.editDiaryItemHandelr = { print("이미지셀 수정")
                        let addMemoVC = AddMemoViewController()
                        addMemoVC.addMemoVM.createTime = diaryItem.createTime
                        addMemoVC.addMemoVM.diaryItem.value = diaryItem
                        self.navigationController?.pushViewController(addMemoVC, animated: true)
                    }
                    imageCell.deleteDiaryItemHandelr = {
                        print("이미지셀 삭제")
                        self.diaryListSingleton.removeDiaryAtIndex(index: indexPath.row)
                    }
                    imageCell.configure(diaryItem)
                    return imageCell
                }
            } else {
                // 이미지가 없는 셀 - CollectionView가 없는 셀
                
                listCell.editDiaryItemHandelr = { print("listCell 수정")
                    let addMemoVC = AddMemoViewController()
                    addMemoVC.addMemoVM.createTime = diaryItem.createTime
                    addMemoVC.addMemoVM.diaryItem.value = diaryItem
                    self.navigationController?.pushViewController(addMemoVC, animated: true) }
                listCell.deleteDiaryItemHandelr = {
                    print("리스트셀 삭제")
                    self.diaryListSingleton.removeDiaryAtIndex(index: indexPath.row)
                }
                
                listCell.configure(diaryItem)
                return listCell
            }
        }
        return imageCell
    }
    
    // refreshControl
    @objc func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing() // 리프레시가 완료되었음을 알림
        }
    }
    
}

// MARK: - UITableViewDelegate
extension DiaryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let diaryDetailVC = DiaryDetailViewController()
        if let diaryItem = diaryListSingleton.diaryList.value?[indexPath.row] {
            diaryDetailVC.diaryDetailVM.diaryItem.value = diaryItem
            diaryDetailVC.diaryDetailVM.diaryListIndex = indexPath.row
            navigationController?.pushViewController(diaryDetailVC, animated: true)
        }
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension DiaryListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiaryListImageTableViewCell.identifier) as! DiaryListImageTableViewCell

        cell.dateLabel.text = ""
        cell.titleLabel.text = ""
        cell.contentLabel.text = ""
        
        for indexPath in indexPaths {
            if let diaryList = diaryListSingleton.filteredDiaryList.value {
                
                let diaryItem = diaryList[indexPath.row]
                cell.configure(diaryItem)
            }
        }
        
    }
}

// MARK: - UI 관련
extension DiaryListViewController {
    // UI 설정
    private func setupUI() {
        view.backgroundColor = .white
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        filterBarView = {
            let view = UIView()
            view.backgroundColor = #colorLiteral(red: 0.9239165187, green: 0.9213962555, blue: 0.9468390346, alpha: 1)
            return view
        }()
        
        filterViewToggleButton = {
            let button = UIButton()
            button.setTitle("전체 / 최신 순", for: .normal)
            button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            button.setImage(UIImage(systemName: "chevron.up"), for: .selected)
            button.tintColor = .black
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = nil
            button.addTarget(self, action: #selector(changeFilterView), for: .touchUpInside)
            button.semanticContentAttribute = .forceRightToLeft
            return button
        }()
        
        filterView = {
            let view = DiaryListFilterView()
            view.categoryButton.addTarget(self, action: #selector(dropDownCategoryFilter), for: .touchUpInside)
            view.dateSortButton.addTarget(self, action: #selector(dropDownDateSort), for: .touchUpInside)
            view.applyButton.addTarget(self, action: #selector(applyFilter), for: .touchUpInside)
            view.resetFilterButton.addTarget(self, action: #selector(resetFilter), for: .touchUpInside)
            view.startDatePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
            view.endDatePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
            view.backgroundColor = #colorLiteral(red: 0.9239165187, green: 0.9213962555, blue: 0.9468390346, alpha: 1)
            view.layer.borderWidth = 0.4
            view.stackView.isHidden = true
            return view
        }()
        
        tableView = {
            let tableView = UITableView()
            tableView.backgroundColor = .white
            tableView.register(DiaryListImageTableViewCell.self, forCellReuseIdentifier: DiaryListImageTableViewCell.identifier)
            tableView.register(DiaryListTableViewCell.self, forCellReuseIdentifier: DiaryListTableViewCell.identifier)
            tableView.showsVerticalScrollIndicator = false
            tableView.separatorStyle = .none
            return tableView
        }()
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        segmentControl = {
            let controller = UISegmentedControl()
            controller.insertSegment(with: UIImage(systemName: "square.grid.3x3"), at: 0, animated: true)
            controller.insertSegment(with: UIImage(systemName: "square.fill.text.grid.1x2"), at: 1, animated: true)
            controller.selectedSegmentIndex = 0
            return controller
        }()
        segmentControl.addTarget(self, action: #selector(changedSegment), for: .valueChanged)
    }
    
    // 레이아웃
    private func setupLayout() {
        view.addSubview(filterBarView)
        view.addSubview(filterView)
        view.addSubview(tableView)
        filterBarView.addSubview(segmentControl)
        filterBarView.addSubview(filterViewToggleButton)
        
        filterBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        segmentControl.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
        }
        
        filterViewToggleButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
            $0.height.equalToSuperview()
        }
        
        filterView.snp.makeConstraints {
            $0.top.equalTo(filterBarView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(filterView.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }
}
