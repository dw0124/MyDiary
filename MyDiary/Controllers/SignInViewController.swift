//
//  LoginViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/03.
//

import UIKit
import SnapKit
import FirebaseAuth

class SignInViewController: UIViewController {

    let signInVM = SignInViewModel()

    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let signUpButton = UIButton()
    let findMyPassword = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.navigationController != nil ? "true" : "false")
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
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
        signUpButton.setTitle("로그인", for: .normal)
        signUpButton.backgroundColor = .blue
        signUpButton.layer.cornerRadius = 5
        signUpButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        
        // 비밀번호 찾기 버튼 설정
        findMyPassword.setTitle("비밀번호 찾기", for: .normal)
        findMyPassword.setTitleColor(.blue, for: .normal)
        findMyPassword.backgroundColor = .white
        findMyPassword.layer.cornerRadius = 5
        findMyPassword.addTarget(self, action: #selector(presentResetPasswordVC), for: .touchUpInside)
        
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signUpButton)
        view.addSubview(findMyPassword)
        
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
        
        findMyPassword.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(20)
            make.leading.equalTo(emailTextField)
        }
    }

    @objc func signIn() {
        signInVM.signInWithEmail(email: emailTextField.text, password: passwordTextField.text)
    }
    
    @objc func presentResetPasswordVC() {
        print(#function)
        let resetPasswordVC = ResetPasswordViewController()
        
        present(resetPasswordVC, animated: true)
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         // 키보드를 내려가게함
         textField.resignFirstResponder()
         
         return true
     }
}
