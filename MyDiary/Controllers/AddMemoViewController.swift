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
    
    lazy var addAddressButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("추가", for: .normal)
        button.addTarget(self, action: #selector(selectAddress), for: .touchUpInside)
        return button
    }()
    
    lazy var addPreviewImagesButton: UIButton = {
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
    let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "선택된 위치 없음"
        return label
    }()
    
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
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()
    
    private let addressStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 지도에서 위치를 선택하고 완료를 누르면 notification을 통해서 위치를 받아옴
        NotificationCenter.default.addObserver(self, selector: #selector(setAddress(_:)), name: Notification.Name("addAddress"), object: nil)
        
        // 오른쪽 상단에 저장 버튼 추가
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
        
        addAddressButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
        
        view.addSubview(addressStackView)
        addressStackView.addArrangedSubview(addAddressButton)
        addressStackView.addArrangedSubview(addressLabel)
        
        view.addSubview(imageStackView)
        imageStackView.addArrangedSubview(addPreviewImagesButton)
        imageStackView.addArrangedSubview(collectionView)
        
        view.addSubview(titleTextField)
        view.addSubview(contentTextView)
        
        addressStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        // 스택 뷰 위치 설정
        imageStackView.snp.makeConstraints { make in
            //make.top.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(addressStackView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        // collectionView 높이 설정
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(72)
        }
        
        // 제목 입력 텍스트 필드
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
    
    // 저장이 오류 또는 완료되었다는 메시지를 보여주기위한 Alert창
    func showAlert(result: Bool, message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            
            if result == true {
                // collectionView로 추가한 데이터 표시하기 위해 notification으로 DiaryListViewController로 데이터 전달
                //NotificationCenter.default.post(name: Notification.Name("addDiaryItem"), object: nil, userInfo: ["diaryItem": self.addMemoVM.diaryItem!])
                DiaryListSingleton.shared.diaryList.value?.insert(self.addMemoVM.diaryItem!, at: 0)
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func saveMemo() {
        self.addMemoVM.address = addressLabel.text ?? ""
        self.addMemoVM.title = titleTextField.text ?? ""
        self.addMemoVM.content = contentTextView.text ?? ""
        
        LoadingIndicator.showLoading(withText: "저장 중")
        self.addMemoVM.saveMemo() { (resultBool, message) in
            self.showAlert(result: resultBool, message: message)
            LoadingIndicator.removeLoading()
        }
    }
    
    // 지도에서 위치를 선택하고 완료를 누르면 notification을 통해서 위치를 받아옴
    @objc func setAddress(_ notification: Notification) {
        if let address = notification.userInfo?["address"] as? String {
            self.addressLabel.text = address
        }
        if let lat = notification.userInfo?["lat"] as? Double, let lng = notification.userInfo?["lng"] as? Double {
            addMemoVM.lat = lat
            addMemoVM.lng = lng
        }
    }
    
    @objc func selectImage() {
        requestPHPhotoLibraryAuthorization {
        }
        self.showImagePicker()
    }
    
    @objc func selectAddress() {
        let mapVC = MapViewController()
        self.navigationController?.pushViewController(mapVC, animated: true)
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
            configuration.selection = .ordered
            
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
                    print("error: \(error.localizedDescription)")
                } else {
                    guard let image = object as? UIImage else { return }
                    DispatchQueue.global().sync {
                        self.addMemoVM.images.value?.append(image)
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

