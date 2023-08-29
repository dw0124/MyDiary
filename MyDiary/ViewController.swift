//
//  ViewController.swift
//  MyDiary
//
//  Created by 김두원 on 2023/08/29.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let mapView = NMFMapView(frame: view.frame)
        //let mapView = NMFNaverMapView(frame: view.frame)
        view.addSubview(mapView)

        let locationOverlay = mapView.locationOverlay
        locationOverlay.hidden = true
        
        mapView.touchDelegate = self
    }


}

extension ViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        print("\(latlng.lat), \(latlng.lng)")
    }
}
