//
//  ExampleJamCams.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import Foundation

struct ExampleJamCams {
    static var oxfordCircus = JamCam(id: "JamCams_00001.07452",
                                     commonName: "Oxford Circus",
                                     placeType: "JamCam",
                                     additionalProperties: [
                                        AdditionalProperty(key: "imageUrl",
                                                           value: "https://oxford-circus.jpg"),
                                        AdditionalProperty(key: "view",
                                                           value: "oxford-circus-view")
                                     ],
                                     lat: 51.5154, lon: -0.14204)
    
    static var stGilesCircus = JamCam(id: "JamCams_00001.07301",
                                      commonName: "St Giles Circus",
                                      placeType: "JamCam",
                                      additionalProperties: [
                                        AdditionalProperty(key: "imageUrl",
                                                           value: "https://st-giles-circus.jpg"),
                                        AdditionalProperty(key: "view",
                                                           value: "st-giles-circus-view")
                                      ],
                                      lat: 51.5164, lon: -0.13022)
    
    static var gowerSt = JamCam(id: "JamCams_00001.07389",
                                commonName: "University St/Gower St",
                                placeType: "JamCam",
                                additionalProperties: [
                                    AdditionalProperty(key: "imageUrl",
                                                       value: "https://gower-st.jpg"),
                                    AdditionalProperty(key: "view",
                                                       value: "gower-st-view")
                                ],
                                lat: 51.5239, lon: -0.1341)
    
    static var exhibitionRd = JamCam(id: "JamCams_00001.06640",
                                     commonName: "Kensington Rd/Exhibition Rd",
                                     placeType: "JamCam",
                                     additionalProperties: [
                                        AdditionalProperty(key: "imageUrl",
                                                           value: "https://exhibition-rd.jpg"),
                                        AdditionalProperty(key: "view",
                                                           value: "exhibition-rd-view")
                                     ],
                                     lat: 51.5017, lon: -0.17483)
    
    private init () {}
}
