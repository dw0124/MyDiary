//
//  SignUpViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/03.
//

import UIKit
import SnapKit
import Foundation

class SignUpViewController: UIViewController {

    let firebaseAuthVM = FirebaseAuthViewModel()
    
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let signUpButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
    }
}

// MARK: - UI 관련
extension SignUpViewController {
    private func setupUI() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // 배경 색상 설정
        view.backgroundColor = .white
        
        // 이메일 텍스트 필드 설정
        emailTextField.placeholder = "이메일"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocapitalizationType = .none
        
        // 비밀번호 텍스트 필드 설정
        passwordTextField.placeholder = "비밀번호"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .password
        passwordTextField.autocapitalizationType = .none
        
        // 회원가입 버튼 설정
        signUpButton.setTitle("회원가입", for: .normal)
        signUpButton.backgroundColor = .green
        signUpButton.layer.cornerRadius = 5
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }

    private func setupLayout() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signUpButton)
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
        }

        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.leading.equalTo(emailTextField)
            make.trailing.equalTo(emailTextField)
        }

        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.leading.equalTo(passwordTextField)
            make.trailing.equalTo(passwordTextField)
            make.height.equalTo(44) // 버튼의 높이 설정
        }
    }
    
    @objc private func signUp() {
        firebaseAuthVM.signUpWithEmail(email: emailTextField.text, password: passwordTextField.text)
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         textField.resignFirstResponder()
         
         return true
     }
}
