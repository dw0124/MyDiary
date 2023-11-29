//
//  DiaryTabBarController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/06.
//

import UIKit
import Foundation

class DiaryTabBarController: UITabBarController {
    
    let mapVC = UINavigationController(rootViewController: MapViewController())
    let memoVC: UINavigationController = UINavigationController(rootViewController: DiaryListViewController())
    let categoryVC: UINavigationController = UINavigationController(rootViewController: CategoryViewController())
    let profileVC = ProfileViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigation()
        setTabBar()
        
        tabBar.backgroundColor = .systemGray6
        tabBar.tintColor = .black
        UITabBar.clearShadow()
        tabBar.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
    }
    
    func setNavigation() {
        memoVC.navigationBar.topItem?.title = "카테고리 없음"
        categoryVC.navigationBar.topItem?.title = "카테고리"
        
        // 오른쪽 상단에 "plus" 버튼 추가
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(pushMemoVC))
        memoVC.navigationBar.topItem?.rightBarButtonItem = rightButton
    }
    
    func setTabBar() {
        mapVC.tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map.fill"), tag: 0)
        categoryVC.tabBarItem = UITabBarItem(title: "카테고리", image: UIImage(systemName: "list.bullet"), tag: 1)
        memoVC.tabBarItem = UITabBarItem(title: "일기", image: UIImage(systemName: "text.book.closed.fill"), tag: 2)
        profileVC.tabBarItem = UITabBarItem(title: "마이페이지", image: UIImage(systemName: "person.fill"), tag: 3)
        

        // 탭 바 컨트롤러에 뷰 컨트롤러를 추가
        viewControllers = [memoVC, categoryVC, mapVC, profileVC]
    }
    
    @objc func pushMemoVC() {
        let addMemoVC = AddMemoViewController()
        memoVC.pushViewController(addMemoVC, animated: false)
    }
}

extension CALayer {
    // Sketch 스타일의 그림자를 생성하는 유틸리티 함수
    func applyShadow(color: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
    }
}

extension UITabBar {
    // 기본 그림자 스타일을 초기화해야 커스텀 스타일을 적용할 수 있다.
    static func clearShadow() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.white
    }
}
