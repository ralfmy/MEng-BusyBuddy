//
//  PlaceExample.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import Foundation

class PlaceExample {
    public var place = Place()
    
    init() {
        place.id = "JamCams_00001.07389"
        place.commonName = "University St/Gower St"
        place.placeType = "JamCam"
        place.imageUrl = "https://s3-eu-west-1.amazonaws.com/jamcams.tfl.gov.uk/00001.07389.jpg"
        place.lat = 51.5239
        place.lon = -0.1341
    }
}
