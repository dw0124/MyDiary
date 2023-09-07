//
//  AddMemoViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/06.
//

import UIKit
import SnapKit
import PhotosUI

class AddMemoViewController: UIViewController {
    
    let addMemoVM = AddMemoViewModel()
    
    let addPreviewImagesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("추가", for: .normal)
        button.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        return button
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PreviewImageCell.self, forCellWithReuseIdentifier:  PreviewImageCell.identifier)
        
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false

        return collectionView
    }()
    
    // UI 요소 정의
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목을 입력하세요"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let textViewPlaceHolder = "내용을 입력하세요"
    lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.text = textViewPlaceHolder
        textView.layer.borderWidth = 0.2
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 8.0
        textView.textColor = .lightGray
        return textView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 오른쪽 상단에 "plus" 버튼 추가
        let rightButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveMemo))
        self.navigationItem.rightBarButtonItem = rightButton
        
        collectionView.delegate = self
        collectionView.dataSource = self
        contentTextView.delegate = self
        
        view.backgroundColor = .white
        
        addMemoVM.images.bind { image in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        // UI를 루트 뷰에 추가
        view.addSubview(stackView)
        stackView.addArrangedSubview(addPreviewImagesButton)
        stackView.addArrangedSubview(collectionView)
        
        view.addSubview(titleTextField)
        view.addSubview(contentTextView)
        
        // 스택 뷰 위치 설정
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        // collectionView 높이 설정
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(72)
        }
        
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        // 내용 입력 텍스트 뷰 위치 설정
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    @objc func saveMemo() {
        self.addMemoVM.title = titleTextField.text ?? ""
        self.addMemoVM.content = contentTextView.text ?? ""
        self.addMemoVM.saveMemo()
    }
    
    @objc func selectImage() {
        requestPHPhotoLibraryAuthorization {
        }
        self.showImagePicker()
    }
    
    func requestPHPhotoLibraryAuthorization(completion: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
            switch status {
            case .limited:
                completion()
            case .authorized:
                completion()
            default:
                break
            }
        }
    }
    
    // 이미지 피커 열기
    func showImagePicker() {
        DispatchQueue.main.async {
            
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 5
            configuration.filter = .images
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            
            self.present(picker, animated: true)
        }
    }

}


extension AddMemoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // picker가 선택이 완료되면 화면 내리기
        picker.dismiss(animated: true)
        
        for result in results {
            // Get all the images that you selected from the PHPickerViewController
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                // Check for errors
                if let error = error {
                    print("Sick error dawg \(error.localizedDescription)")
                } else {
                    // Convert the image into Data so we can upload to firebase
                    if let image = object as? UIImage {
                        self.addMemoVM.images.value?.append(image)
                        
                    } else {
                        print("There was an error.")
                    }
                }
            }
        }
        
    }
}
    
extension AddMemoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addMemoVM.images.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewImageCell.identifier, for: indexPath) as? PreviewImageCell else {
            return UICollectionViewCell()
        }
        DispatchQueue.main.async {
            cell.imageView.image = self.addMemoVM.images.value?[indexPath.item]
        }
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        return cell
    }
    
    
}

extension AddMemoViewController: UICollectionViewDelegate {
    // 삭제 버튼을 눌렀을 때 호출되는 메서드
    @objc func deleteImage(_ sender: UIButton) {
        let index = sender.tag
        addMemoVM.images.value?.remove(at: index)
        collectionView.reloadData()
    }
}

extension AddMemoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }
}

