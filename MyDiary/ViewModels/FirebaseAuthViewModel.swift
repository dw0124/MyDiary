//
//  SignInViewModel.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/04.
//

import Foundation

import FirebaseAuth
import FirebaseDatabase
import FirebaseCore

import GoogleSignIn

import KakaoSDKAuth
import KakaoSDKUser

import Alamofire

class FirebaseAuthViewModel {
    
    /// 로그인 메소드 - 로그인 성공시 화면 전환
    func signInWithEmail(email: String?, password: String?) {
        if let email = email, let password = password {
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { (auth, error) in
                if let error = error as? AuthErrorCode {
                    switch error.code {
                    case .invalidEmail, .wrongPassword:
                        print("이메일 또는 비밀번호가 일치하지 않습니다.")
                    case .userNotFound:
                        print("등록되지 않은 이메일입니다.")
                    default:
                        print("이메일을 확인 해주세요.")
                    }
                    return
                }
                
                if auth != nil {
                    print("로그인 성공")
                    let mapViewController = DiaryTabBarController()
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(mapViewController, animated: false)
                }
            }
        }
    }
    
    /// 회원가입을 위한 메소드 Firebase Auth와 Realtime DB에 유저 정보 저장
    func signUpWithEmail(email: String?, password: String?) {
        if let email = email, let password = password {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print(error)
                    return
                }
                
                if let user = authResult?.user {
                    // 사용자 고유 ID
                    let userID = user.uid
                    
                    // Realtime Database에 사용자 정보 저장
                    let userRef = Database.database().reference().child("users").child(userID)
                    
                    // 사용자 정보를 딕셔너리 형태로 저장
                    let userInfo = ["email": email]
                    
                    // 사용자 정보를 Realtime Database에 저장
                    userRef.setValue(userInfo) { error, _ in
                        if let error = error {
                            print("Error saving user data: \(error)")
                        } else {
                            print("User data saved successfully!")
                        }
                    }
                }
            }
        }
    }
    
    /// 비밀번호 재설정 메일을 보내기 위한 메소드
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
    
    
    // 구글 로그인
    func googleSingIn(_ viewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            guard error == nil else { return }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                if result != nil {
                    let mapViewController = DiaryTabBarController()
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(mapViewController, animated: false)
                }
            }
        }
    }
    
    // 카카오 로그인
    func kakaoSignIn() {
        if let user = Auth.auth().currentUser {
            print(user.email ?? "email", "으로 로그인 중 입니다.")
            return
        }
        
        print("카카오 로그인 진행")
        // 카카오톡 실행 가능 여부 확인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print("카카오톡 로그인 에러 \(error.localizedDescription)")
                } else {
                    print("loginWithKakaoTalk() success.")
                    
                    //do something
                    if let oauthToken = oauthToken {
                        //self.signUpWithKakao()
                        
                        //self.requestKakao(accessToken: oauthToken.accessToken) //이 부분이 추가되었습니다.
                    }
                }
            }
        } else {
            // 카카오톡 설치가 안되어있는 경우 modal방식으로 진행
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print("카카오톡 로그인 에러 \(error.localizedDescription)")
                }
                else {
                    print("loginWithKakaoAccount() success.")
                    if let oauthToken = oauthToken {
                        self.signUpWithKakao()
                        
                        // 서버를 사용하여 토큰을 통한 로그인
                        //self.requestKakao(accessToken: oauthToken.accessToken)
                    }
                }
            }
        }
        
    }
    
    
    private func signUpWithKakao() {
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                if let email = user?.kakaoAccount?.email {
                    self.signUpWithEmail(email: "kakao_" + email, password: String(describing: user?.id), kakao: true)
                }
            }
        }
    }
    
    private func signUpWithEmail(email: String?, password: String?, kakao: Bool) {
        if let email = email, let password = password {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error as? AuthErrorCode {
                    if error.code == AuthErrorCode.emailAlreadyInUse {
                        print("이미 존재하는 아이디입니다. 로그인 시작")
                        self.signInWithEmail(email: email, password: password)
                    }
                    return
                }
                
                if let user = authResult?.user {
                    // 사용자 고유 ID
                    let userID = user.uid
                    
                    // Realtime Database에 사용자 정보 저장
                    let userRef = Database.database().reference().child("users").child(userID)
                    
                    // 사용자 정보를 딕셔너리 형태로 저장
                    let userInfo = ["email": email]
                    
                    // 사용자 정보를 Realtime Database에 저장
                    userRef.setValue(userInfo) { error, _ in
                        if let error = error {
                            print("Error saving user data: \(error)")
                        } else {
                            print("User data saved successfully!")
                            self.signInWithEmail(email: email, password: password)
                        }
                    }
                }
            }
        }
    }
    
    
    /* 카카오 로그인 - 서버 사용
    func requestKakao(accessToken: String) {
        let url = URL(string: String(format: "%@/verifyToken", Bundle.main.object(forInfoDictionaryKey: "VALIDATION_SERVER_URL") as! String))!
        let parameters: [String: String] = ["token": accessToken]
        let req = AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json", "Accept":"application/json"])
        req.responseJSON { response in
            switch response.result {
            case .success(let value):
                print("success: requestKakao")
                guard let object = value as? [String: Any] else {
                    return
                }
                guard let firebaseToken = object["firebase_token"]  else { return }
                self.signInToFirebaseWithToken(firebaseToken: firebaseToken as! String )
            case .failure(let error):
                print("error : requestkakao",error)
            }
            
        }
    }
    
    func signInToFirebaseWithToken(firebaseToken: String) {
        Auth.auth().signIn(withCustomToken: firebaseToken) { ( result, error) in
            guard let result = result else {
                // result가 nil이면 인증 실패
                print("Error signing in: \(error!)")
                //self.delegate?.emailLogin(self, failedWithError: error!)
                return
            }
            print("Signed in as user: \(result.user.uid)")
            // 인증 성공했을 때의 동작
            let mapViewController = DiaryTabBarController()
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(mapViewController, animated: false)
        }
    }
    */
}
