//
//  MapSelectionViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/10/04.
//

import UIKit
import NMapsMap
import SnapKit

class MapSelectionViewController: UIViewController {
    
    let mapVM = MapViewModel()
    
    var mapView: NMFMapView!
    var locationOverlay: NMFLocationOverlay!
    var marker: NMFMarker?
    let locationManager = CLLocationManager()
    
    // 선택한 위치의 주소를 보여주기 위한 label
    var addressLabel = PaddingLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        
        setupAddButton()
        setupLocationManager()
        setupMapView()
        setupBinding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupUI() {
        
        addressLabel = {
            let label = PaddingLabel(padding: UIEdgeInsets(top: 8.0, left: 6.0, bottom: 8.0, right: 6.0))
            label.backgroundColor = .white
            label.text = "선택된 위치 없음"
            label.textAlignment = .left
            label.font = UIFont.systemFont(ofSize: 16)
            label.layer.cornerRadius = 8.0
            label.layer.borderWidth = 0.3
            label.layer.borderColor = UIColor.black.cgColor
            
            return label
        }()
    }
    
    private func setupLayout() {
        mapView.addSubview(addressLabel)
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            //make.height.equalTo(32)
        }
    }
    
    // 오른쪽 상단에 추가 버튼 설정
    private func setupAddButton() {
        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    // 추가 버튼 탭
    @objc func addButtonTapped() {
        let userInfo: [String: Any] = [
            "address": mapVM.selectedAddressStr.value ?? "선택된 위치 없음",
            "lat": mapVM.lat,
            "lng": mapVM.lng
        ]
        
        NotificationCenter.default.post(name: Notification.Name("addAddress"), object: nil, userInfo: userInfo)
        self.navigationController?.popViewController(animated: true)
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
            guard let lat = self?.locationManager.location?.coordinate.latitude,
                  let lng = self?.locationManager.location?.coordinate.longitude else { return }
            let nmgLatLng = NMGLatLng(lat: lat, lng: lng)
            let cameraUpdate = NMFCameraUpdate(scrollTo: nmgLatLng)
            self?.mapView.moveCamera(cameraUpdate)
            
            self?.locationOverlay.location = nmgLatLng
        }
        
        setupUI()
        setupLayout()
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
        
        mapVM.selectedAddressStr.bind { address in
            self.addressLabel.text = address
        }
    }
}

// MARK: - CLLocationManagerDelegate: 위치관련 delegate
extension MapSelectionViewController: CLLocationManagerDelegate {
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
extension MapSelectionViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        mapVM.lat = latlng.lat
        mapVM.lng = latlng.lng
        mapVM.reverseGeocoding(lat: latlng.lng, lng: latlng.lat)
        
        // 마커가 있는지 확인하고 있다면 마커를 지도에서 삭제
        if marker?.mapView != nil {
            marker?.mapView = nil
        }
        
        let postion = NMGLatLng(lat: mapVM.lat, lng: mapVM.lng)
        
        // 마커 관련 설정
        marker = NMFMarker(position: postion)
        marker?.width = 44
        marker?.height = 64
        //marker.iconImage = NMFOverlayImage(image: markerImage)
        
        // 마커를 mapView에 추가
        marker?.mapView = self.mapView
        
    }
}


class PaddingLabel: UILabel {
    private var padding = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)

    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right

        return contentSize
    }
}
