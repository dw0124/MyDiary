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
    
    var mapView: NMFMapView!
    var locationOverlay: NMFLocationOverlay!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        setupMapView()
        setupMarkers()
        setupBinding()
    }
    
    // 위치 관리자 설정
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    // 네이버 지도 설정
    private func setupMapView() {
        mapView = NMFMapView(frame: view.frame)
        mapView.touchDelegate = self
        view.addSubview(mapView)
        
        locationOverlay = mapView.locationOverlay
        locationOverlay.hidden = false
        
        DispatchQueue.main.async { [weak self] in
            // 현재 위치로 mapView의 카메라를 이동
            guard let lat = self?.locationManager.location?.coordinate.latitude,
                  let lng = self?.locationManager.location?.coordinate.longitude else { return }
            let nmgLatLng = NMGLatLng(lat: lat, lng: lng)
            let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLatLng)
            self?.mapView.moveCamera(cameraUpdate)
            
            self?.locationOverlay.location = nmgLatLng
        }
    }
    
    // 마커 표시를 위한 메소드
    private func setupMarkers() {
        let diaryListSingleton = DiaryListSingleton.shared
        
        // diaryList 바인딩을 통해 데이터가 바뀌면 마커를 표시
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
                            // 마커 위치를 위한 상수
                            let postion = NMGLatLng(lat: lat, lng: lng)
                            
                            // ImageMarkerView를 이미지로 사용
                            let markerImage = imageMarkerView.toImage()
                            
                            // 마커 관련 설정
                            let marker = NMFMarker(position: postion)
                            marker.width = 44
                            marker.height = 64
                            marker.iconImage = NMFOverlayImage(image: markerImage)
                            
                            // 마커를 터치했을때 실행되는 클로저
                            marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
                                print(diaryItem.createTime)
                                return true
                            }
                            
                            // 마커를 mapView에 추가
                            marker.mapView = self.mapView
                            
                            imageMarkerView.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
    // 바인딩 설정
    private func setupBinding() {
        mapVM.currentLocation.bind { location in
            if let lat = location?[0], let lng = location?[1] {
                DispatchQueue.main.async {
                    self.locationOverlay.location = NMGLatLng(lat: lat, lng: lng)
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate: 위치관련 delegate
extension MapViewController: CLLocationManagerDelegate {
    // 위치 정보 계속 업데이트 -> 위도 경도 받아옴
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapVM.currentLocation.value?[0] = Double(location.coordinate.latitude)
            mapVM.currentLocation.value?[1] = Double(location.coordinate.longitude)
        }
    }
    
    // 위도 경도 받아오기 에러
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error)
    }
}

// MARK: - NMFMapViewTouchDelegate: 네이버 지도 터치 관련 delegate
extension MapViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
//        mapVM.lat = latlng.lat
//        mapVM.lng = latlng.lng
//        mapVM.reverseGeocoding(lat: latlng.lng, lng: latlng.lat)
    }
}
