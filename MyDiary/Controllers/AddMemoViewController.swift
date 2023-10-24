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
    var totalStackView = UIStackView()
    
    // textView를 사용하면 delegate를 통해서 변경 - 키보드에 의해 가려지는것을 방지
    var textViewDidEiditing = false
    
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
        
        // 키보드에 의해서 가려지는 것을 방지하기 위한 notification
        registerForKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeRegisterForKeyboardNotification()
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
        let dropDown = DropDown()
        
        dropDown.anchorView = categoryButton
        dropDown.dataSource = CategorySingleton.shared.categoryList.value?.map { $0.category } ?? ["카테고리 없음"]
        
        dropDown.selectionAction = { (index: Int, item: String) in
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
            return stackView
        }()
        
        imageStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 16
            stackView.alignment = .leading
            return stackView
        }()
        
        totalStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 16
            stackView.alignment = .leading
           return stackView
        }()
        
        // titleTextField, contentTextView를 사용해서 키보드가 보여지면 상단에 완료 버튼 추가
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBtnClicked))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        titleTextField.inputAccessoryView = toolbar
        contentTextView.inputAccessoryView = toolbar
    }
    
    private func setupLayout() {
        
        let addressSeperatorView = UIView()
        addressSeperatorView.backgroundColor = .gray
        
        let imageSeperatorView = UIView()
        imageSeperatorView.backgroundColor = .gray
        
        addressStackView.addArrangedSubview(addAddressButton)
        addressStackView.addArrangedSubview(addressSeperatorView)
        addressStackView.addArrangedSubview(addressLabel)
        
        imageStackView.addArrangedSubview(addPreviewImagesButton)
        imageStackView.addArrangedSubview(imageSeperatorView)
        imageStackView.addArrangedSubview(collectionView)
        
        totalStackView.addArrangedSubview(categoryButton)
        totalStackView.addArrangedSubview(addressStackView)
        totalStackView.addArrangedSubview(imageStackView)
        totalStackView.addArrangedSubview(titleTextField)
        totalStackView.addArrangedSubview(contentTextView)
        view.addSubview(totalStackView)
        
        // addressStackView
        addAddressButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalTo(addAddressButton.snp.height)
            $0.centerY.equalToSuperview()
        }

        addressSeperatorView.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalToSuperview()
        }
        
        addressLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
        }
        
        addressStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        // imageStackView
        addPreviewImagesButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    
        imageSeperatorView.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(64)
        }
        
        collectionView.snp.makeConstraints {
            $0.height.equalTo(72)
        }
        
        imageStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        // titleTextField
        titleTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        // contentTextView
        contentTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        
        totalStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.leading.trailing.equalToSuperview().inset(12)
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
            textView.text = ""
             textView.textColor = .black
        }
        textViewDidEiditing = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewDidEiditing = false
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .lightGray
        }
    }
}

// TextField, TextView가 키보드에 의해서 가려지는것을 방지
extension AddMemoViewController {
    // 키보드가 있을때 화면을 터치하면 내려감
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    func registerForKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeRegisterForKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        self.view.frame.origin.y = 0
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

         if textViewDidEiditing == true {
            keyboardAnimate(keyboardSize: keyboardSize, object: totalStackView)
        }
    }
    
    func keyboardAnimate(keyboardSize: CGRect ,object: AnyObject){
        // 키보드의 minY가 textView의 maxY보다 작으면 가려짐
        if keyboardSize.minY <= object.frame.maxY {
            self.view.frame.origin.y = keyboardSize.minY - object.frame.maxY - 10
        }
    }
    
    @objc func doneBtnClicked() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.1) {
            self.view.frame.origin.y = 0
        }
    }
}
