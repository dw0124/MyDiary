//
//  ResetPasswordViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/04.
//

import UIKit
import Foundation
import SnapKit

class ResetPasswordViewController: UIViewController {
    
    let signInVM = SignInViewModel()
    
    let emailTextField = UITextField()
    let resetPasswordButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // 이메일 텍스트 필드 설정
        emailTextField.placeholder = "이메일"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocapitalizationType = .none
        
        // 비밀번호 찾기 버튼 설정
        resetPasswordButton.setTitle("비밀번호 찾기", for: .normal)
        resetPasswordButton.backgroundColor = .blue
        resetPasswordButton.layer.cornerRadius = 5
        resetPasswordButton.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
        
        view.addSubview(emailTextField)
        view.addSubview(resetPasswordButton)
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
        }

        resetPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.leading.equalTo(emailTextField)
            make.trailing.equalTo(emailTextField)
            make.height.equalTo(44) // 버튼의 높이 설정
        }
        
    }
    
    @objc func resetPassword() {
        signInVM.findPassword(email: emailTextField.text) { (result, message) in
            self.showAlert(result: result, message: message)
        }
    }
    
    func showAlert(result: Bool, message: String) {
        switch result {
        case true:
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                alertController.dismiss(animated: true, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        case false:
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        

    }
}
