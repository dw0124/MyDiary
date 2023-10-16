//
//  SceneDelegate.swift
//  MyDiary
//
//  Created by 김두원 on 2023/08/29.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // rootViewController를 변경하는 메소드
    func changeRootVC(_ vc: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        window.rootViewController = vc // 전환
        
        UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil, completion: nil)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        //로그인 정보를 확인하고 로그인이 되어있으면 메인VC, 없으면 로그인VC를 보여줌
        if let _ = Auth.auth().currentUser {

            let mapViewController = DiaryTabBarController()

            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(mapViewController, animated: false)
        } else {
            let signInViewController = SignInViewController()

            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootVC(signInViewController, animated: false)
        }
        
        
//        let mainViewController = MapSelectionViewController()
//        let navigationController = UINavigationController(rootViewController: mainViewController)
//        window?.rootViewController = navigationController
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

