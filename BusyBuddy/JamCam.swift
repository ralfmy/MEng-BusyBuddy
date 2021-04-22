//
//  CodableJamCam.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 01/11/2020.
//

import UIKit
import os.log

//  Decode JSON response from TfL Unified API into this JamCam type.

public final class JamCam: Codable, Equatable, Identifiable, ObservableObject {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "JamCam")

    public let id: String
    let commonName: String
    let placeType: String
    let additionalProperties: [AdditionalProperty]
    let lat: Double
    let lon: Double
    var isBookmark: Bool = false
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
        if let property = self.additionalProperties.first(where: {$0.key == "imageUrl"}) {
            return property.value
        }
        return "None"
    }
    
    public func getCameraView() -> String {
        if let property = self.additionalProperties.first(where: { $0.key == "view" }) {
            return property.value
        }
        return "None"
    }
    
    public func downloadImage() -> UIImage {
        if let data = try? Data(contentsOf: URL(string: self.getImageUrl())!) {
            if let image = UIImage(data: data) {
                return image
            }
        }
        return UIImage()
    }
    
    public func formattedCommonName() -> String {
        if let index = self.commonName.firstIndex(of: "/") {
            var commonName = self.commonName
            commonName.insert("\n", at: commonName.index(after: index))
            return commonName
        }
        return self.commonName
    }
    
    public func toggleBookmark() {
        self.isBookmark.toggle()
    }
    
    public func updateBusyScore(busyScore: BusyScore?) {
        self.objectWillChange.send()
        self.busyScore = busyScore
    }
    
    public static func == (lhs: JamCam, rhs: JamCam) -> Bool {
        if (lhs.commonName == rhs.commonName && lhs.placeType == rhs.placeType && lhs.lat == rhs.lat && lhs.lon == rhs.lon)
        {
            return true
        } else {
            return false
        }
    }
}

extension JamCam {
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

