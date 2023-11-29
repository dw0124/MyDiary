//
//  MapViewModel.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/15.
//

import Foundation
import Alamofire

class MapViewModel {
    
    var currentLocation: Observable<[Double]> = Observable([0, 0])
    var lat: Double = 0
    var lng: Double = 0
    var address: Address?
    var selectedAddressStr: Observable<String> = Observable("선택된 위치 없음")
    
    func reverseGeocoding(lat: Double, lng: Double) {
        let headers: HTTPHeaders = [
            "X-NCP-APIGW-API-KEY-ID": "oepugcp8e9",
            "X-NCP-APIGW-API-KEY": "RSluwb9FiWt672d6sXxe24cVUhAzaRq7Ld99BDr6"
        ]
        let parameters = [
            "coords":"\(lat), \(lng)",
            "output":"json",
            "orders":"roadaddr,admcode"
        ]
        
        AF.request(
            "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc",
            method: .get,
            parameters: parameters,
            //encoding: JSONEncoding.default,
            headers: headers
        ).responseDecodable(of: Address.self) { (response) in
            switch response.result {
            case .success(let address):
                self.address = address
                
                if address.results[0].name == "admcode" {
                    self.selectedAddressStr.value = "\(address.results[0].region.area1.name + " " + address.results[0].region.area2.name + " " + address.results[0].region.area3.name + " " + address.results[0].region.area4.name)"
                } else if address.results[0].name == "roadaddr" {
                    self.selectedAddressStr.value = "\(address.results[1].region.area1.name + " " + address.results[1].region.area2.name + " " + address.results[1].region.area3.name + " " + address.results[1].region.area4.name + " " + (address.results[0].land?.addition0.value ?? ""))"
                } else {
                    self.selectedAddressStr.value = "선택된 지역에 대한 정보가 없습니다."
                }
            case .failure:
                print(response.error.debugDescription)
            }
        }
        
    }
    
}
