//
//  IntentHandler.swift
//  PlaceIntent
//
//  Created by Ralf Michael Yap on 02/01/2021.
//
//  With help from: https://developer.apple.com/documentation/widgetkit/making-a-configurable-widget

import Intents

class IntentHandler: INExtension, SelectPlaceIntentHandling {
    func providePlaceOptionsCollection(for intent: SelectPlaceIntent, with completion: @escaping (INObjectCollection<PlaceItem>?, Error?) -> Void) {
        var places = [PlaceItem]()
        
        if let data = UserDefaults(suiteName: "group.com.zcabrmy.BusyBuddy")!.object(forKey: "Bookmarks") as? Data {
            if let bookmarks = try? JSONDecoder().decode([Place].self, from: data) {
                bookmarks.forEach { place in
                    let placeItem = PlaceItem(identifier: place.id, display: place.commonName)
                    placeItem.placeType = place.placeType
                    placeItem.imageUrl = place.getImageUrl()
                    placeItem.lat = NSNumber(value: place.lat)
                    placeItem.lon = NSNumber(value: place.lon)
                    places.append(placeItem)
                }
            }
        }
        
        let collection = INObjectCollection(items: places)
        completion(collection, nil)
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
