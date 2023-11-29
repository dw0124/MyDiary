//
//  ProfileViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/04.
//

import UIKit
import Foundation
import SnapKit

import FirebaseAuth
import FirebaseCore

import KakaoSDKUser
import KakaoSDKAuth

class ProfileViewController: UIViewController {
    
    let signOutButton = UIButton()
    
    @objc func signOut() {
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        guard let delegate = sceneDelegate else {
            print("에어러런멍ㅎ먈")
            return
        }
        
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("logout() success.")
                let mainViewController = SignInViewController()
                let navigationController = UINavigationController(rootViewController: mainViewController)
                delegate.window?.rootViewController = navigationController
            }
        }
        
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let mainViewController = SignInViewController()
                let navigationController = UINavigationController(rootViewController: mainViewController)
                delegate.window?.rootViewController = navigationController
            }
            catch {
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signOutButton.setTitle("로그아웃", for: .normal)
        signOutButton.setTitleColor(.black, for: .normal)
        signOutButton.tintColor = .black
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        
        view.addSubview(signOutButton)
        
        signOutButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        view.backgroundColor = .white
    }
    
}
