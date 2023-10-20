//
//  AddMemoViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/06.
//

import UIKit
import SnapKit
import PhotosUI
import DropDown

class AddMemoViewController: UIViewController {
    
    let addMemoVM = AddMemoViewModel()
    
    // UI 요소 정의
    let textViewPlaceHolder = "내용을 입력하세요"   // UITextViewDelegate를 통해서 contentTextView의 placeholder처럼 사용
    var categoryButton = DropDownButton()
    lazy var addAddressButton = UIButton()
    lazy var addPreviewImagesButton = UIButton()
    var addressLabel = UILabel()
    var titleTextField = UITextField()
    var contentTextView = UITextView()
    var addressStackView = UIStackView()
    var imageStackView = UIStackView()
    
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
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 지도에서 위치를 선택하고 완료를 누르면 notification을 통해서 위치를 받아옴
        NotificationCenter.default.addObserver(self, selector: #selector(setAddress(_:)), name: Notification.Name("addAddress"), object: nil)
        
        setupUI()
        setupLayout()
        setBinding()
        
        setupDelegate()
    }
}

// MARK: - 일기 저장 관련
extension AddMemoViewController {
    
    // 저장이 오류 또는 완료되었다는 메시지를 보여주기위한 Alert창
    func showAlert(result: Bool, message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            
            if result == true {
                DiaryListSingleton.shared.diaryList.value?.insert(self.addMemoVM.diaryItem!, at: 0)
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MapSelectionViewController를 열고 지도에서 위치를 선택하기 위한 메소드
    @objc func selectAddress() {
        let mapSelectionVC = MapSelectionViewController()
        self.navigationController?.pushViewController(mapSelectionVC, animated: true)
    }
    
    // 일기를 저장하는 메소드
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
    
    // 카테고리 버튼 선택
    @objc func setCategory() {
        print(#function)
        let dropDown = DropDown()
        
        dropDown.anchorView = categoryButton
        dropDown.dataSource = CategorySingleton.shared.categoryList.value?.map { $0.category } ?? ["카테고리 없음"]
        
        dropDown.selectionAction = { (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.addMemoVM.category = item
            self.categoryButton.label.text = item
        }
        
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.cornerRadius = 15
        
        dropDown.show()
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
    
}

// MARK: - UI 관련
extension AddMemoViewController {
    private func setupDelegate() {
        collectionView.delegate = self
        collectionView.dataSource = self
        contentTextView.delegate = self
    }
    
    private func setupUI() {
        // 오른쪽 상단에 저장 버튼 추가
        let rightButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveMemo))
        self.navigationItem.rightBarButtonItem = rightButton
        
        view.backgroundColor = .white
        
        categoryButton = {
            let button = DropDownButton()
            button.label.text = "카테고리 없음"
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .systemGray6
            button.layer.cornerRadius = 10
            button.layer.shadowOpacity = 0.5
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 0)
            button.layer.shadowRadius = 1.0
            button.layer.masksToBounds = false
            button.addTarget(self, action: #selector(setCategory), for: .touchUpInside)
            return button
        }()
        
        addAddressButton = {
            let button = UIButton(type: .system)
            //button.setTitle("추가", for: .normal)
            button.setImage(UIImage(named: "add-location.png"), for: .normal)
            button.addTarget(self, action: #selector(selectAddress), for: .touchUpInside)
            button.imageView?.contentMode = .scaleAspectFit
            return button
        }()
        
        addPreviewImagesButton = {
            let button = UIButton(type: .system)
            //button.setTitle("추가", for: .normal)
            button.setImage(UIImage(named: "picturePlus_32.png"), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
            return button
        }()
        
        addressLabel = {
            let label = UILabel()
            label.text = "선택된 위치 없음"
            return label
        }()
        
        titleTextField = {
            let textField = UITextField()
            textField.placeholder = "제목을 입력하세요"
            textField.borderStyle = .roundedRect
            return textField
        }()
        
        //let textViewPlaceHolder = "내용을 입력하세요"
        contentTextView = {
            let textView = UITextView()
            textView.text = textViewPlaceHolder
            textView.layer.borderWidth = 0.2
            textView.layer.borderColor = UIColor.lightGray.cgColor
            textView.layer.cornerRadius = 8.0
            textView.textColor = .lightGray
            textView.font = UIFont.systemFont(ofSize: 16)
            return textView
        }()
        
        addressStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 16
            stackView.alignment = .leading
            stackView.distribution = .fill
            return stackView
        }()
        
        imageStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 16
            stackView.alignment = .leading
            return stackView
        }()
    }
    
    private func setupLayout() {
        
        let addressSeperatorView = UIView()
        addressSeperatorView.backgroundColor = .gray
        
        let imageSeperatorView = UIView()
        imageSeperatorView.backgroundColor = .gray
        
        view.addSubview(categoryButton)
        
        view.addSubview(addressStackView)
        addressStackView.addArrangedSubview(addAddressButton)
        addressStackView.addArrangedSubview(addressSeperatorView)
        addressStackView.addArrangedSubview(addressLabel)
        
        view.addSubview(imageStackView)
        imageStackView.addArrangedSubview(addPreviewImagesButton)
        imageStackView.addArrangedSubview(imageSeperatorView)
        imageStackView.addArrangedSubview(collectionView)
        
        view.addSubview(titleTextField)
        view.addSubview(contentTextView)
        
        // 카테고리 버튼
        categoryButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            //make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        addressStackView.snp.makeConstraints { make in
            //make.top.equalTo(view.safeAreaLayoutGuide)
            //make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            //make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.top.equalTo(categoryButton.snp.bottom).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        // 지도 버튼 설정
        addAddressButton.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
        
        addressSeperatorView.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalToSuperview()
        }
        
        addressLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
        }
        
        // 이미지 스택 뷰 위치 설정
        imageStackView.snp.makeConstraints { make in
            //make.top.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(addressStackView.snp.bottom).offset(16)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        addPreviewImagesButton.snp.makeConstraints { make in
            make.height.equalToSuperview()
            //make.centerY.equalToSuperview()
        }
        
        imageSeperatorView.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(64)
        }
        
        // collectionView 설정
        collectionView.snp.makeConstraints { make in
            make.height.equalTo(72)
            //make.centerY.equalToSuperview()
        }
        
        
        // 제목 입력 텍스트 필드
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(8)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        // 내용 입력 텍스트 뷰 설정
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    func setBinding() {
        addMemoVM.images.bind { image in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
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

// MARK: - UICollectionViewDataSource
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

// MARK: - UICollectionViewDelegate
extension AddMemoViewController: UICollectionViewDelegate {
    // 삭제 버튼을 눌렀을 때 호출되는 메서드
    @objc func deleteImage(_ sender: UIButton) {
        let index = sender.tag
        addMemoVM.images.value?.remove(at: index)
        collectionView.reloadData()
    }
}

// MARK: - UITextViewDelegate
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

