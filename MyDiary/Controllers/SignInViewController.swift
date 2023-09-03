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


    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let signUpButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        signUpButton.setTitle("로그인", for: .normal)
        signUpButton.backgroundColor = .blue
        signUpButton.layer.cornerRadius = 5
        signUpButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        
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

    @objc func signIn() {
        // 로그인 버튼이 눌렸을 때의 동작을 구현
        // 예: Firebase 인증을 사용하여 사용자 로그인 처리
        if let email = emailTextField.text, let password = passwordTextField.text {
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { (auth, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                if auth != nil {
                    print("로그인 성공")
                    let mapViewController = MapViewController() // MyViewController는 대상 뷰 컨트롤러 클래스명
                    
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(mapViewController, animated: false)
                }
            }
            
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         // 키보드를 내려가게함
         textField.resignFirstResponder()
         
         return true
     }
}
