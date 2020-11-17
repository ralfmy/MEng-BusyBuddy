//
//  Place.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 01/11/2020.
//

import Foundation

//  Decode JSON response from TfL Unified API into this Place type.

struct CodablePlace: Codable, Equatable, Identifiable {
    let id: String
    let commonName: String
    let placeType: String
    let additionalProperties: [AdditionalProperty]
    let lat: Double
    let lon: Double
    
    static func == (lhs: CodablePlace, rhs: CodablePlace) -> Bool {
        if (lhs.commonName == rhs.commonName && lhs.placeType == rhs.placeType && lhs.lat == rhs.lat && lhs.lon == rhs.lon)
        {
            return true
        } else {
            return false
        }
    }
    
    func getImageUrl() -> String {
        let imageUrl = self.additionalProperties.filter({$0.key == "imageUrl"})
        if imageUrl.count != 0 {
            return imageUrl[0].value
        } else {
            return "None"
        }
    }
    
}
