//
//  CodablePlace.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 01/11/2020.
//

import Foundation
import os.log

//  Decode JSON response from TfL Unified API into this PlacE type.

public final class Place: Codable, Equatable, Identifiable, ObservableObject {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "Place")

    public let id: String
    let commonName: String
    let placeType: String
    let additionalProperties: [AdditionalProperty]
    let lat: Double
    let lon: Double
    @Published public var busyScore: BusyScore?
        
    init(id: String, commonName: String, placeType: String, additionalProperties: [AdditionalProperty], lat: Double, lon: Double, busyScore: BusyScore? = nil) {
        self.id = id
        self.commonName = commonName
        self.placeType = placeType
        self.additionalProperties = additionalProperties
        self.lat = lat
        self.lon = lon
        self.busyScore = busyScore
    }
    
    public func getImageUrl() -> String {
        let imageUrl = self.additionalProperties.filter({$0.key == "imageUrl"})
        if imageUrl.count != 0 {
            return imageUrl[0].value
        } else {
            return "None"
        }
    }
    
    public func updateBusyScore(busyScore: BusyScore) {
        self.busyScore = busyScore
    }
    
//    public func busyScoreNeedsUpdate() -> Bool {
//        let busyScore = self.busyScore
//        if Date() > busyScore.date.addingTimeInterval(5) || busyScore.score == .none  {
//            self.logger.info("INFO: BusyScore older than 5 minutes, requires update.")
//            return true
//        } else {
//            self.logger.info("INFO: BusyScore does not need update.")
//            return false
//        }
//    }
    
    public static func == (lhs: Place, rhs: Place) -> Bool {
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

struct AdditionalProperty: Codable {
    let key: String
    let value: String
}

