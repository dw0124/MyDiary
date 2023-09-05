//
//  SignInViewModel.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/04.
//

import Foundation
import FirebaseAuth

class SignInViewModel {
    
    func signInWithEmail(email: String?, password: String?) {
        if let email = email, let password = password {
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
    
    func findPassword(email: String?, completion: @escaping (Bool, String) -> ()) {
        if let email = email {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                var message = ""
                
                if let error = error as? AuthErrorCode {
                    switch error.code {
                    case .invalidEmail:
                        message = "이메일 형식을 확인해주세요."
                    case .userNotFound:
                        message = "등록되지 않은 이메일입니다."
                    default:
                        message = "이메일을 확인 해주세요."
                    }
                    completion(false, message)
                } else {
                    // 오류 없이 비밀번호 재설정 이메일이 성공적으로 전송된 경우
                    message = "비밀번호 재설정 이메일을 전송했습니다."
                    completion(true, message)
                }
            }
        }
    }
    
}
