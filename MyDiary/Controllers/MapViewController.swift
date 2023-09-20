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

    let locationManager = CLLocationManager()
    var current: [Double] = [0, 0]
    var currentOverlay: Observable<[Double]> = Observable([0, 0])
    
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
    }
    
    @objc func addButtonTapped() {
        NotificationCenter.default.post(name: Notification.Name("addAddress"), object: nil, userInfo: ["address": self.mapVM.selectedAddressStr])
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
        let mapView = NMFMapView(frame: view.frame)
        mapView.touchDelegate = self
        view.addSubview(mapView)
        
        // 사용자 위치 표시하는 오버레이
        let locationOverlay = mapView.locationOverlay
        locationOverlay.hidden = false
        
        DispatchQueue.main.async {
            // 네이버 지도 카메라 움직이기
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: self.current[0], lng: self.current[1]))
            mapView.moveCamera(cameraUpdate)
            
            locationOverlay.location = NMGLatLng(lat: self.current[0], lng: self.current[1])
        }
        
        // 사용자 위치 표시하는 오버레이 위치변경을 위한 바인딩
        self.currentOverlay.bind { value in
            if let lat = self.currentOverlay.value?[0], let lng = self.currentOverlay.value?[1] {
                DispatchQueue.main.async {
                    locationOverlay.location = NMGLatLng(lat: lat, lng: lng)
                }
            }
        }
    }
    
    private func setMarker() {
        
    }
}

extension MapViewController: CLLocationManagerDelegate {
    // 위치 정보 계속 업데이트 -> 위도 경도 받아옴
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            current[0] = Double(location.coordinate.latitude)
            current[1] = Double(location.coordinate.longitude)
            
            print(current[1], current[0])
            
            currentOverlay.value?[0] = Double(location.coordinate.latitude)
            currentOverlay.value?[1] = Double(location.coordinate.longitude)
        }
    }
    
    // 위도 경도 받아오기 에러
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error)
    }
}

extension MapViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        print(latlng.lng, latlng.lat)
        mapVM.reverseGeocoding(lat: latlng.lng, lng: latlng.lat)
        
        currentOverlay.value?[0] = latlng.lat
        currentOverlay.value?[1] = latlng.lng
        
    }
}
