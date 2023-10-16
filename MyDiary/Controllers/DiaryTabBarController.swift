//
//  DiaryTabBarController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/06.
//

import UIKit
import Foundation

class DiaryTabBarController: UITabBarController {
    
    let mapVC = MapViewController()
    let memoVC: UINavigationController = UINavigationController(rootViewController: DiaryListViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigation()
        setTabBar()
    }
    
    func setNavigation() {
        memoVC.navigationBar.topItem?.title = "메인"
        
        // 오른쪽 상단에 "plus" 버튼 추가
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(pushMemoVC))
        memoVC.navigationBar.topItem?.rightBarButtonItem = rightButton
    }
    
    func setTabBar() {
        mapVC.tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "circle.fill"), tag: 0)
        memoVC.tabBarItem = UITabBarItem(title: "일기", image: UIImage(systemName: "circle.fill"), tag: 1)

        // 탭 바 컨트롤러에 뷰 컨트롤러를 추가
        viewControllers = [memoVC, mapVC]
    }
    
    @objc func pushMemoVC() {
        let addMemoVC = AddMemoViewController()
        memoVC.pushViewController(addMemoVC, animated: false)
    }
}
