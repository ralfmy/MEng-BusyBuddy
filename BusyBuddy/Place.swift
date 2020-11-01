//
//  Place.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 01/11/2020.
//

import Foundation

struct Place: Encodable, Decodable, Equatable {
    let commonName: String
    let placeType: String
    let additionalProperties: [AdditionalProperty]
    let lat: Double
    let lon: Double
    
    static func == (lhs: Place, rhs: Place) -> Bool {
        if (lhs.commonName == rhs.commonName && lhs.placeType == rhs.placeType && lhs.lat == rhs.lat && lhs.lon == rhs.lon)
        {
            return true
        } else {
            return false
        }
    }
    
    func getImageUrl() -> String {
        return self.additionalProperties.filter({$0.key == "imageUrl"})[0].value
    }
    
}
