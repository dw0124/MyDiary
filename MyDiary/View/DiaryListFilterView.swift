//
//  DiaryListFilterView.swift
//  MyDiary
//
//  Created by 김두원 on 2023/10/16.
//

import UIKit
import SnapKit

class DiaryListFilterView: UIView {

//    let categoryButton = UIButton()
//    let dateSortButton = UIButton()
    let categoryButton = DropDownButton()
    let dateSortButton = DropDownButton()
    let applyButton = UIButton()
    let resetFilterButton = UIButton()
    
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    let slashView = UIView()
    
    let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupLayout()
    }
    
    private func setup() {
        categoryButton.label.text = "카테고리 없음"
        //categoryButton.setTitle("없음", for: .normal)
        categoryButton.setTitleColor(.black, for: .normal)
        categoryButton.setTitleColor(.gray, for: .highlighted)
        categoryButton.backgroundColor = .systemGray6
        categoryButton.layer.cornerRadius = 10
        categoryButton.layer.shadowOpacity = 0.5
        categoryButton.layer.shadowColor = UIColor.black.cgColor
        categoryButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        categoryButton.layer.shadowRadius = 1.0
        categoryButton.layer.masksToBounds = false
        
        dateSortButton.label.text = "최신 순"
        //dateSortButton.setTitle("최신 순", for: .normal)
        dateSortButton.setTitleColor(.black, for: .normal)
        dateSortButton.setTitleColor(.gray, for: .highlighted)
        dateSortButton.backgroundColor = .systemGray6
        dateSortButton.layer.cornerRadius = 10
        dateSortButton.layer.shadowOpacity = 0.5
        dateSortButton.layer.shadowColor = UIColor.black.cgColor
        dateSortButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        dateSortButton.layer.shadowRadius = 1.0
        dateSortButton.layer.masksToBounds = false
        
        startDatePicker.preferredDatePickerStyle = .compact
        startDatePicker.datePickerMode = .date
        startDatePicker.locale = Locale(identifier: "ko-KR")
        startDatePicker.timeZone = .autoupdatingCurrent
        //startDatePicker.addTarget(self, action: #selector(opendDatePicker), for: .valueChanged)

        endDatePicker.preferredDatePickerStyle = .compact
        endDatePicker.datePickerMode = .date
        endDatePicker.locale = Locale(identifier: "ko-KR")
        endDatePicker.timeZone = .autoupdatingCurrent
        //endDatePicker.addTarget(self, action: #selector(opendDatePicker), for: .valueChanged)
        
        slashView.backgroundColor = .black
        
        applyButton.setTitle("적용하기", for: .normal)
        applyButton.setTitleColor(.black, for: .normal)
        applyButton.setTitleColor(.gray, for: .highlighted)
        applyButton.backgroundColor = .systemGray6
        applyButton.layer.cornerRadius = 10
        applyButton.layer.shadowOpacity = 0.5
        applyButton.layer.shadowColor = UIColor.black.cgColor
        applyButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        applyButton.layer.shadowRadius = 1.0
        applyButton.layer.masksToBounds = false
        
        resetFilterButton.setTitle("초기화", for: .normal)
        resetFilterButton.setTitleColor(.black, for: .normal)
        resetFilterButton.setTitleColor(.gray, for: .highlighted)
        resetFilterButton.backgroundColor = .systemGray6
        resetFilterButton.layer.cornerRadius = 10
        resetFilterButton.layer.shadowOpacity = 0.5
        resetFilterButton.layer.shadowColor = UIColor.black.cgColor
        resetFilterButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        resetFilterButton.layer.shadowRadius = 1.0
        resetFilterButton.layer.masksToBounds = false
    }
    
    private func setupLayout() {
        
        let filterStackView = UIStackView()
        filterStackView.axis = .horizontal
        filterStackView.alignment = .center
        filterStackView.distribution = .equalCentering
        filterStackView.spacing = 12
        
        filterStackView.addArrangedSubview(categoryButton)
        filterStackView.addArrangedSubview(dateSortButton)
        
        let dateStackView = UIStackView()
        dateStackView.axis = .horizontal
        dateStackView.alignment = .center
        dateStackView.distribution = .equalCentering
        dateStackView.spacing = 8
        
        dateStackView.addArrangedSubview(startDatePicker)
        dateStackView.addArrangedSubview(slashView)
        dateStackView.addArrangedSubview(endDatePicker)
        
        let applyButtonStackView = UIStackView()
        applyButtonStackView.axis = .horizontal
        applyButtonStackView.alignment = .center
        applyButtonStackView.distribution = .fillEqually
        applyButtonStackView.spacing = 12
        
        applyButtonStackView.addArrangedSubview(resetFilterButton)
        applyButtonStackView.addArrangedSubview(applyButton)
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 12
        
        stackView.addArrangedSubview(filterStackView)
        stackView.addArrangedSubview(dateStackView)
        stackView.addArrangedSubview(applyButtonStackView)
        
        addSubview(stackView)
        
        filterStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        categoryButton.snp.makeConstraints {
            //$0.width.equalTo(filterStackView.snp.width).multipliedBy(0.5)
            $0.width.equalTo(150)
        }

        dateSortButton.snp.makeConstraints {
            //$0.width.equalTo(filterStackView.snp.width).multipliedBy(0.4)
            $0.width.equalTo(120)
        }
        
        startDatePicker.snp.makeConstraints {
            $0.leading.equalToSuperview()
            //$0.width.equalTo(dateStackView.snp.width).multipliedBy(0.45)
            //$0.height.equalTo(10)
        }

        slashView.snp.makeConstraints {
            $0.width.equalTo(8)
            $0.height.equalTo(1)
        }
        
        endDatePicker.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            //$0.width.equalTo(dateStackView.snp.width).multipliedBy(0.45)
        }
        
        applyButtonStackView.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        
        dateStackView.snp.makeConstraints {
            $0.width.equalToSuperview()
            //$0.height.equalTo(filterStackView)
        }
        
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
