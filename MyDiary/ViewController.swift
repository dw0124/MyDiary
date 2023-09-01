//
//  ViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/08/29.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {

    var locationManager = CLLocationManager()
    var current: [Double] = [0, 0]
    var currentOverlay: Observable<[Double]> = Observable([0, 0])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        let mapView = NMFMapView(frame: view.frame)
        
        mapView.touchDelegate = self
        
        view.addSubview(mapView)
        
        let locationOverlay = mapView.locationOverlay
        locationOverlay.hidden = false
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
            }
            DispatchQueue.main.async {
                // 네이버 지도 카메라 움직이기
                let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: self.current[0], lng: self.current[1]))
                mapView.moveCamera(cameraUpdate)
                
                locationOverlay.location = NMGLatLng(lat: self.current[0], lng: self.current[1])
            }
        }
        
        
        
        self.currentOverlay.bind { value in
            if let lat = self.currentOverlay.value?[0], let lng = self.currentOverlay.value?[1] {
                print("Observable")
                
                print(lat, lng)
                
                DispatchQueue.main.async {
                    locationOverlay.location = NMGLatLng(lat: lat, lng: lng)

                }
                
            }
        }
        

    }
}

extension ViewController: CLLocationManagerDelegate {
    // 위치 정보 계속 업데이트 -> 위도 경도 받아옴
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            current[0] = Double(location.coordinate.latitude)
            current[1] = Double(location.coordinate.longitude)
            
            currentOverlay.value?[0] = Double(location.coordinate.latitude)
            currentOverlay.value?[1] = Double(location.coordinate.longitude)
            
            
            //print(current[0], current[1])
        }
    }
    
    // 위도 경도 받아오기 에러
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .notDetermined {
            
        } else {
            
        }
    }
}

extension ViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        
        currentOverlay.value?[0] = latlng.lat
        currentOverlay.value?[1] = latlng.lng
        
        print("\(latlng.lat), \(latlng.lng)")
    }
}
