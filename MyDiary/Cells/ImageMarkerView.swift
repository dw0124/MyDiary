//
//  ImageMarkerView.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/25.
//

import UIKit
import Foundation
import SnapKit

class ImageMarkerView: UIView {
    
    let imgView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.image = UIImage(named: "Banner_0")
        return imageView
    }()
    
    private let decorateView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 5
        return view
    }()
    
    override var intrinsicContentSize: CGSize {
        let imgSize: CGFloat = 44
        let decorationHeight: CGFloat = 10 + 8
        return CGSize(width: imgSize, height: imgSize + decorationHeight)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: DiaryItem, completion: @escaping (UIImage?) -> Void) {
//        imgView.layer.borderColor = UIColor(named: data.decorateColor)?.cgColor
//        decorateView.backgroundColor = UIColor(named: data.decorateColor)
        if let urlStr = data.imageURL?.first {
            
            ImageCacheManager.shared.loadImageFromStorage(storagePath: urlStr) { [weak self] image in
                DispatchQueue.main.async {
                    self?.imgView.image = image
                    let markerImage: UIImage? = self?.toImage()
                    completion(markerImage)
                }
            }
        }
            
//            if let url = URL(string: urlStr) {
//                let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//                    if let error = error {
//                        print("HumanMarker Image Download Error: \(error.localizedDescription)")
//                        completion(nil)
//                        return
//                    }
//                    if let data = data, let image = UIImage(data: data) {
//                        print(image)
//                        DispatchQueue.main.async {
//                            self?.imgView.image = image
//                            let markerImage: UIImage? = self?.toImage()
//                            completion(markerImage)
//                        }
//                    } else {
//                        completion(nil)
//                    }
//                }
//                task.resume()
//            } else {
//                completion(nil)
//            }
    }
    
    private func setupLayout() {
        addSubview(imgView)
        addSubview(decorateView)
        
        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        decorateView.snp.makeConstraints { make in
            make.centerX.equalTo(imgView)
            make.top.equalTo(imgView.snp.bottom).offset(8)
            make.width.height.equalTo(10)
        }
    }
}

extension UIView {
    
    func toImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
