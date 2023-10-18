//
//  CategoryViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/10/17.
//

import Foundation
import UIKit
import SnapKit

class CategoryViewController: UIViewController {
    
    let categorySingleton = CategorySingleton.shared
    
    let categoryTextField = UITextField()
    let categoryTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBind()
        
        view.backgroundColor = .white
        
        categoryTextField.placeholder = "새로 추가할 카테고리를 입력하세요."
        
        let addButton = UIButton()
        addButton.setTitle("추가", for: .normal)
        addButton.backgroundColor = .blue
        addButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        
        view.addSubview(categoryTextField)
        view.addSubview(categoryTableView)
        view.addSubview(addButton)
        
        categoryTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        addButton.snp.makeConstraints {
            $0.centerY.equalTo(categoryTextField)
            $0.trailing.equalTo(categoryTextField)
        }
        
        categoryTableView.snp.makeConstraints {
            $0.top.equalTo(categoryTextField.snp.bottom).offset(10)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        categoryTextField.delegate = self
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
    }
    
    @objc func addCategory() {
        if let categoryName = categoryTextField.text, !categoryName.isEmpty {
            categorySingleton.addCategory(categoryName)
            
            categoryTextField.text = ""
            categoryTableView.reloadData()
        }
    }
    
    private func setupBind() {
        categorySingleton.categoryList.bind { categoryList in
            self.categoryTableView.reloadData()
        }
    }
}

// MARK: - UITableView
extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorySingleton.categoryList.value?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") ?? UITableViewCell(style: .default, reuseIdentifier: "CategoryCell")
        cell.textLabel?.text = categorySingleton.categoryList.value?[indexPath.row]
        return cell
    }
}

// MARK: - UITextField
extension CategoryViewController: UITextFieldDelegate {
    // 텍스트 필드에 입력한 카테고리가 존재하는지 확인하기 위한 역할
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(categorySingleton.categoryList.value?.contains(textField.text ?? ""))
    }
}
