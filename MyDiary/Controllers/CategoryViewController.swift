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
    let addButton = UIButton()
    
    let categoryTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBind()
        
        view.backgroundColor = .white
        
        categoryTextField.addTarget(self, action: #selector(enableAddCategoryButton), for: .editingChanged)
        categoryTextField.placeholder = "새로 추가할 카테고리를 입력하세요."
        categoryTextField.clearButtonMode = .whileEditing
        categoryTableView.register(CategoryListTableViewCell.self, forCellReuseIdentifier: CategoryListTableViewCell.identifier)
        categoryTableView.isUserInteractionEnabled = true
        
        addButton.setTitle("추가", for: .normal)
        addButton.setTitleColor(.systemGray, for: .normal)
        addButton.tintColor = .systemGray
        addButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        
        let stackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 6
            return stackView
        }()
        
        stackView.addArrangedSubview(categoryTextField)
        stackView.addArrangedSubview(addButton)
        
        view.addSubview(stackView)
        view.addSubview(categoryTableView)
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
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
    
    @objc func enableAddCategoryButton() {
        if categoryTextField.text == "" {
            addButton.setTitleColor(.systemGray, for: .normal)
            addButton.tintColor = .systemGray
            addButton.isUserInteractionEnabled = false
        } else {
            addButton.setTitleColor(.systemBlue, for: .normal)
            addButton.tintColor = .systemBlue
            addButton.isUserInteractionEnabled = true
        }
    }
    
    @objc func addCategory() {
        let check = categorySingleton.categoryList.value?.contains(where: { categoryItem in
            categoryItem.category == categoryTextField.text
        }) ?? false
        
        if check {
            let alertController = UIAlertController(title: nil, message: "이미 존재하는 카테고리입니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                alertController.dismiss(animated: true, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            if let categoryName = categoryTextField.text, !categoryName.isEmpty {
                // 카테고리 추가
                categorySingleton.addCategory(categoryName)
                
                // 텍스트 필드 초기화
                categoryTextField.text = ""
                
                // 버튼 비활성화
                addButton.setTitleColor(.systemGray, for: .normal)
                addButton.tintColor = .systemGray
                addButton.isUserInteractionEnabled = false
                
                categoryTableView.reloadData()
            }
        }
    }
    
    private func setupBind() {
        categorySingleton.categoryList.bind { categoryList in
            self.categoryTableView.reloadData()
        }
    }
    
    @objc private func deleteCategory(_ sender: UIButton) {
        print(#function, sender.tag)
        
        guard let cateogryName = categorySingleton.categoryList.value?[sender.tag].category else { return }
        
        let alertController = UIAlertController(title: "카테고리 삭제", message: "'\(cateogryName)' 삭제 하시겠습니까?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            alertController.dismiss(animated: true, completion: {
                self.categorySingleton.deleteCategory(sender.tag)
            })
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableView
extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorySingleton.categoryList.value?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = categoryTableView.dequeueReusableCell(withIdentifier: CategoryListTableViewCell.identifier) as? CategoryListTableViewCell else {
            return UITableViewCell()
        }
        cell.categoryLabel.text = categorySingleton.categoryList.value?[indexPath.row].category
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteCategory(_:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - UITextField
extension CategoryViewController: UITextFieldDelegate {
    // 텍스트 필드에 입력한 카테고리가 존재하는지 확인하기 위한 역할
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print(categorySingleton.categoryList.value?.contains(textField.text ?? ""))
    }
}
