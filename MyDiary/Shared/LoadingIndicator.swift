//
//  LoadingIndicator.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/11.
//

import UIKit
import Foundation

class LoadingIndicator {
    
    static let loadingContainerTag = 999
    
    static func showLoading(withText text: String? = nil) {
        DispatchQueue.main.async {
            // 최상단에 있는 window 객체 획득
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            guard let window = windowScene?.windows.last else { return }
            
            // Loading Indicator 컨테이너 생성
            let loadingContainer = UIView(frame: window.frame)
            loadingContainer.backgroundColor = UIColor(white: 0, alpha: 0.6)
            loadingContainer.tag = loadingContainerTag
            
            // Activity Indicator 추가
            let loadingIndicatorView = UIActivityIndicatorView(style: .large)
            loadingIndicatorView.center = loadingContainer.center
            loadingIndicatorView.color = .white
            loadingIndicatorView.startAnimating()
            
            loadingContainer.addSubview(loadingIndicatorView)
            
            // Text Label 추가
            if let text = text {
                let label = UILabel()
                label.text = text
                label.textColor = .white
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 18)
                
                // 이 예제에서는 Label을 Indicator 아래에 위치시킵니다.
                let indicatorFrame = loadingIndicatorView.frame
                let labelFrame = CGRect(x: 0, y: indicatorFrame.maxY + 16, width: loadingContainer.frame.width, height: 30)
                label.frame = labelFrame
                
                loadingContainer.addSubview(label)
            }
            
            // window에 Loading Indicator 컨테이너 추가
            window.addSubview(loadingContainer)
        }
    }
    
    static func removeLoading() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.last else { return }

        DispatchQueue.main.async {
            window.subviews.filter({ $0.tag == loadingContainerTag }).forEach { $0.removeFromSuperview() }
        }
    }
}
