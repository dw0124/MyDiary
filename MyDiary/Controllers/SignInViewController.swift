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

    let firebaseAuthVM = FirebaseAuthViewModel()

    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let signInButton = UIButton()
    let signUpButton = UIButton()
    let findMyPassword = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // 로그인 버튼 설정
        signInButton.setTitle("로그인", for: .normal)
        signInButton.backgroundColor = .blue
        signInButton.layer.cornerRadius = 5
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        
        // 회원가입 버튼 설정
        signUpButton.setTitle("회원가입", for: .normal)
        signUpButton.backgroundColor = .white
        signUpButton.layer.cornerRadius = 5
        signUpButton.addTarget(self, action: #selector(presentSignUpVC), for: .touchUpInside)
        
        // 비밀번호 찾기 버튼 설정
        findMyPassword.setTitle("비밀번호 찾기", for: .normal)
        findMyPassword.setTitleColor(.blue, for: .normal)
        findMyPassword.backgroundColor = .white
        findMyPassword.layer.cornerRadius = 5
        findMyPassword.addTarget(self, action: #selector(presentResetPasswordVC), for: .touchUpInside)
        
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
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

        signInButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.leading.equalTo(passwordTextField)
            make.trailing.equalTo(passwordTextField)
            make.height.equalTo(44) // 버튼의 높이 설정
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(20)
            make.leading.equalTo(emailTextField)
        }
        
        findMyPassword.snp.makeConstraints { make in
            make.top.equalTo(signInButton.snp.bottom).offset(20)
            make.trailing.equalTo(emailTextField)
        }
    }

    @objc func signIn() {
        firebaseAuthVM.signInWithEmail(email: emailTextField.text, password: passwordTextField.text)
    }
    
    @objc func presentSignUpVC() {
        print(#function)
        let signUpVC = SignUpViewController()
        
        present(signUpVC, animated: true)
    
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
