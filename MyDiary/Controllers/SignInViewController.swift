//
//  LoginViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/03.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon

import Alamofire

class SignInViewController: UIViewController {

    let firebaseAuthVM = FirebaseAuthViewModel()

    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let signInButton = UIButton()
    let signUpButton = UIButton()
    let findMyPassword = UIButton()
    let googleSignInButton = GIDSignInButton()
    let kakaoSignInButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
    }
}

// MARK: - 로그인 관련
extension SignInViewController {
    // 이메일과 비밀번호 텍스트 필드를 확인하여 로그인 버튼 비활성화
    @objc func enableSigninButton() {
        if passwordTextField.text == "" || emailTextField.text == "" {
            signInButton.backgroundColor = .systemGray
            signInButton.isUserInteractionEnabled = false
        } else {
            signInButton.backgroundColor = .systemBlue
            signInButton.isUserInteractionEnabled = true
        }
    }
    
    @objc func signIn() {
        firebaseAuthVM.signInWithEmail(email: emailTextField.text, password: passwordTextField.text)
    }
    
    @objc func presentSignUpVC() {
        let signUpVC = SignUpViewController()
        
        present(signUpVC, animated: true)
    
    }
    
    @objc func presentResetPasswordVC() {
        let resetPasswordVC = ResetPasswordViewController()
        
        present(resetPasswordVC, animated: true)
    }
    
    // 구글 로그인
    @objc func googleSignIn() {
        firebaseAuthVM.googleSingIn(self)
    }
    
    @objc func kakaoSignIn() {
        firebaseAuthVM.kakaoSignIn()
    }
    
    
    @objc func logout() {
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("logout() success.")
            }
        }
        
        if Auth.auth().currentUser != nil {
            do { try Auth.auth().signOut() }
            catch { print(error) }
        }
    }
}

// MARK: - UI 관련
extension SignInViewController {
    private func setupUI() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        view.backgroundColor = .white
        
        // 이메일 텍스트 필드 설정
        emailTextField.placeholder = "이메일"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocapitalizationType = .none
        emailTextField.clearButtonMode = .whileEditing
        emailTextField.addTarget(self, action: #selector(enableSigninButton), for: .editingChanged)
        
        // 비밀번호 텍스트 필드 설정
        passwordTextField.placeholder = "비밀번호"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .password
        passwordTextField.autocapitalizationType = .none
        passwordTextField.clearButtonMode = .whileEditing
        passwordTextField.addTarget(self, action: #selector(enableSigninButton), for: .editingChanged)
        
        // 로그인 버튼 설정
        signInButton.setTitle("로그인", for: .normal)
        signInButton.backgroundColor = .systemGray
        signInButton.isUserInteractionEnabled = false
        signInButton.layer.cornerRadius = 5
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        
        // 회원가입 버튼 설정
        signUpButton.setTitle("회원가입", for: .normal)
        signUpButton.setTitleColor(.blue, for: .normal)
        signUpButton.backgroundColor = .white
        signUpButton.layer.cornerRadius = 5
        signUpButton.addTarget(self, action: #selector(presentSignUpVC), for: .touchUpInside)
        
        // 비밀번호 찾기 버튼 설정
        findMyPassword.setTitle("비밀번호 찾기", for: .normal)
        findMyPassword.setTitleColor(.blue, for: .normal)
        findMyPassword.backgroundColor = .white
        findMyPassword.layer.cornerRadius = 5
        findMyPassword.addTarget(self, action: #selector(presentResetPasswordVC), for: .touchUpInside)
        
        // 구글 로그인 버튼 설정
        googleSignInButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        
        // 카카오 로그인 버튼 설정
        kakaoSignInButton.setImage(UIImage(named: "kakao_login_large_wide"), for: .normal)
        kakaoSignInButton.addTarget(self, action: #selector(kakaoSignIn), for: .touchUpInside)
    }

    private func setupLayout() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        view.addSubview(findMyPassword)
        view.addSubview(googleSignInButton)
        view.addSubview(kakaoSignInButton)
        
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
        
        googleSignInButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(50)
            $0.leading.equalTo(passwordTextField)
            $0.trailing.equalTo(passwordTextField)
            $0.height.equalTo(44)
        }
        
        kakaoSignInButton.snp.makeConstraints {
            $0.bottom.equalTo(googleSignInButton.snp.top).offset(-12)
            $0.leading.equalTo(passwordTextField)
            $0.trailing.equalTo(passwordTextField)
            $0.height.equalTo(44)
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
