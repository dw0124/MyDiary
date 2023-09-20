//
//  MapViewModel.swift
//  MyDiary
//
//  Created by 김두원 on 2023/09/15.
//

import Foundation
import Alamofire

class MapViewModel {
    
    var address: Address?
    var selectedAddressStr: String = ""
    
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
                    self.selectedAddressStr = "\(address.results[0].region.area1.name + " " + address.results[0].region.area2.name + " " + address.results[0].region.area3.name + " " + address.results[0].region.area4.name)"
                } else {
                    self.selectedAddressStr = "\(address.results[1].region.area1.name + " " + address.results[1].region.area2.name + " " + address.results[1].region.area3.name + " " + address.results[1].region.area4.name + " " + (address.results[0].land?.addition0.value ?? ""))"
                }
            case .failure:
                print(response.error.debugDescription)
            }
        }
        
    }
    
}
