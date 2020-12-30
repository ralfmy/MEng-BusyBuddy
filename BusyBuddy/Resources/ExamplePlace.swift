//
//  PlaceExample.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import Foundation

struct ExamplePlaces {
    static var oxfordCircus = Place(id: "JamCams_00001.07389", commonName: "Oxford Circus", placeType: "JamCam", additionalProperties: [AdditionalProperty(key: "imageUrl", value: "https://s3-eu-west-1.amazonaws.com/jamcams.tfl.gov.uk/00001.07452.jpg")], lat: 51.5154, lon: -0.14204)
    
    static var stGilesCircus = Place(id: "JamCams_00001.07301", commonName: "St Giles Circus", placeType: "JamCam", additionalProperties: [AdditionalProperty(key: "imageUrl", value: "https://s3-eu-west-1.amazonaws.com/jamcams.tfl.gov.uk/00001.07301.jpg")], lat: 51.5164, lon: -0.13022)
    
    static var gowerSt = Place(id: "JamCams_00001.07389", commonName: "University St/Gower St", placeType: "JamCam", additionalProperties: [AdditionalProperty(key: "imageUrl", value: "https://s3-eu-west-1.amazonaws.com/jamcams.tfl.gov.uk/00001.07389.jpg")], lat: 51.5239, lon: -0.1341)
    
    static var exhibitionRd = Place(id: "JamCams_00001.06640", commonName: "Kensington Rd/Exhibition Rd", placeType: "JamCam", additionalProperties: [AdditionalProperty(key: "imageUrl", value: "https://s3-eu-west-1.amazonaws.com/jamcams.tfl.gov.uk/00001.06640.jpg")], lat: 51.5017, lon: -0.17483)
    
    private init () {}
}
