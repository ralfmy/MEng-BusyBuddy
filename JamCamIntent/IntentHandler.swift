//
//  IntentHandler.swift
//  JamCamIntent
//
//  Created by Ralf Michael Yap on 02/01/2021.
//
//  With help from: https://developer.apple.com/documentation/widgetkit/making-a-configurable-widget

import Intents

class IntentHandler: INExtension, SelectJamCamIntentHandling {
    func provideJamCamOptionsCollection(for intent: SelectJamCamIntent, with completion: @escaping (INObjectCollection<JamCamItem>?, Error?) -> Void) {
        var jamCams = [JamCamItem]()
        
        if let data = UserDefaults(suiteName: "group.com.zcabrmy.BusyBuddy")!.object(forKey: "Bookmarks") as? Data {
            if let bookmarks = try? JSONDecoder().decode([JamCam].self, from: data) {
                bookmarks.forEach { jamCam in
                    let jamCamItem = JamCamItem(identifier: jamCam.id, display: jamCam.commonName)
                    jamCamItem.placeType = jamCam.placeType
                    jamCamItem.imageUrl = jamCam.getImageUrl()
                    jamCamItem.lat = NSNumber(value: jamCam.lat)
                    jamCamItem.lon = NSNumber(value: jamCam.lon)
                    jamCams.append(jamCamItem)
                }
            }
        }
        
        let collection = INObjectCollection(items: jamCams)
        completion(collection, nil)
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
