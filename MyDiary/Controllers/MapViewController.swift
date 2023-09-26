//
//  ViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/08/29.
//

import UIKit
import NMapsMap

class MapViewController: UIViewController {
    
    let mapVM = MapViewModel()
    
    // 맵뷰 실행시 카메라 위치를 현재 좌표로 옮기기 위한 배열
    var current: [Double] = [0, 0]

    var mapView: NMFMapView!
    var locationOverlay:  NMFLocationOverlay!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped) // 버튼을 탭했을 때 실행할 메서드
        )
 
        self.navigationItem.rightBarButtonItem = rightButton
        
        setLocationManager()
        setMapView()
        setMarker()
        setBinding()
    }
    
    @objc func addButtonTapped() {
        let userInfo: [String: Any] = [
            "address": mapVM.selectedAddressStr,
            "lat": mapVM.lat,
            "lng": mapVM.lng
        ]
        
        NotificationCenter.default.post(name: Notification.Name("addAddress"), object: nil, userInfo: userInfo)
        self.navigationController?.popViewController(animated: true)
    }
}

extension MapViewController {
    
    // 위치를 받아오기 위한 메소드
    private func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    private func setMapView() {
        // 지도 표시
        mapView = NMFMapView(frame: view.frame)
        mapView.touchDelegate = self
        view.addSubview(mapView)
        
        // 사용자 위치 표시하는 오버레이
        locationOverlay = mapView.locationOverlay
        locationOverlay.hidden = false
   
        DispatchQueue.main.async {
            // 네이버 지도 카메라 움직이기
            let nmgLatLng = NMGLatLng(lat: self.current[0], lng: self.current[1])
            let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLatLng)
            self.mapView.moveCamera(cameraUpdate)
            
            self.locationOverlay.location = nmgLatLng
        }
    }
    
    private func setMarker() {
        let diaryListSingleton = DiaryListSingleton.shared
        
        diaryListSingleton.diaryList.bind { diaryList in
            diaryList?.forEach { diaryItem in
                
                guard let lat = diaryItem.lat, let lng = diaryItem.lng else { return }
                guard let imageURL = diaryItem.imageURL?.first else { return }
                
                // 마커로 표시할 이미지를 위한 ImageMarkerView
                // -> toImage()를 사용해서 UIView를 이미지로 만들어서 마커 이미지에 적용
                let imageMarkerView = ImageMarkerView()
                self.view.addSubview(imageMarkerView)
                imageMarkerView.snp.makeConstraints {
                    $0.leading.equalToSuperview().offset(-50)
                    $0.top.equalToSuperview().offset(-100)
                    $0.width.equalTo(44)
                    $0.height.equalTo(64)
                }
                
                ImageCacheManager.shared.loadImageFromStorage(storagePath: imageURL) { image in
                    DispatchQueue.main.async {
                        imageMarkerView.imgView.image = image
                        DispatchQueue.main.async {
                            let postion = NMGLatLng(lat: lat, lng: lng)
                            
                            // ImageMarkerView를 이미지로 사용
                            let markerImage = imageMarkerView.toImage()
                            let marker = NMFMarker(position: postion)
                            marker.width = 44
                            marker.height = 64
                            marker.iconImage = NMFOverlayImage(image: markerImage)
                            
                            // 마커를 터치했을때 실행되는 클로저
                            marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
                                print(diaryItem.createTime)
                                return true
                            }
                            
                            marker.mapView = self.mapView
                            
                            imageMarkerView.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
    private func setBinding() {
        // 사용자 위치 표시하는 오버레이 위치변경을 위한 바인딩
        mapVM.currentLocation.bind { location in
            if let lat = location?[0], let lng = location?[1] {
                DispatchQueue.main.async {
                    self.locationOverlay.location = NMGLatLng(lat: lat, lng: lng)
                }
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    // 위치 정보 계속 업데이트 -> 위도 경도 받아옴
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            current[0] = Double(location.coordinate.latitude)
            current[1] = Double(location.coordinate.longitude)
            
            mapVM.currentLocation.value?[0] = Double(location.coordinate.latitude)
            mapVM.currentLocation.value?[1] = Double(location.coordinate.longitude)
        }
    }
    
    // 위도 경도 받아오기 에러
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error)
    }
}

extension MapViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        
        print("???")
        
        // revser geocoding으로 주소 정보 받아옴
        mapVM.lat = latlng.lat
        mapVM.lng = latlng.lng
        mapVM.reverseGeocoding(lat: latlng.lng, lng: latlng.lat)
    }
}


extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
