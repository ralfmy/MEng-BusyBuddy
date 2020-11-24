//
//  CodablePlace.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 01/11/2020.
//

import Foundation
import os.log

//  Decode JSON response from TfL Unified API into this PlacE type.

class Place: Codable, Equatable, Identifiable {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "Place")

    let id: String
    let commonName: String
    let placeType: String
    let additionalProperties: [AdditionalProperty]
    let lat: Double
    let lon: Double
    
    var busyScore = BusyScore()
    
    init(id: String, commonName: String, placeType: String, additionalProperties: [AdditionalProperty], lat: Double, lon: Double) {
        self.id = id
        self.commonName = commonName
        self.placeType = placeType
        self.additionalProperties = additionalProperties
        self.lat = lat
        self.lon = lon
    }
    
    public func getImageUrl() -> String {
        let imageUrl = self.additionalProperties.filter({$0.key == "imageUrl"})
        if imageUrl.count != 0 {
            return imageUrl[0].value
        } else {
            return "None"
        }
    }
    
    public func busyScoreNeedsUpdate() -> Bool {
        let busyScore = self.busyScore
        if Date() > busyScore.date.addingTimeInterval(10)  {
            self.logger.info("INFO: BusyScore older than 5 minutes, requires update.")
            return true
        } else {
            self.logger.info("INFO: BusyScore does not need update.")
            return false
        }
    }
    
    static func == (lhs: Place, rhs: Place) -> Bool {
        if (lhs.commonName == rhs.commonName && lhs.placeType == rhs.placeType && lhs.lat == rhs.lat && lhs.lon == rhs.lon)
        {
            return true
        } else {
            return false
        }
    }
}

extension Place {
    enum CodingKeys: CodingKey {
        case id
        case commonName
        case placeType
        case additionalProperties
        case lat
        case lon
    }
}
