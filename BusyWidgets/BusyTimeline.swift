//
//  BusyTimeline.swift
//  BusyWidgetsExtension
//
//  Created by Ralf Michael Yap on 30/12/2020.
//

import WidgetKit
import UIKit

struct BusyTimeline: IntentTimelineProvider {
    
    typealias Entry = BusyEntry
    typealias Intent = SelectPlaceIntent

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), place: ExamplePlaces.oxfordCircus)
    }
    
    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (Entry) -> Void) {
        let entry = Entry(date: Date(), place: ExamplePlaces.oxfordCircus)
        completion(entry)
    }
    
    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        
        guard let placeItem = configuration.place else {
            let entry = Entry(date: currentDate, place: ExamplePlaces.oxfordCircus)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
            return
        }
        
        let place = Place(id: placeItem.identifier!, commonName: placeItem.displayString, placeType: placeItem.placeType!, additionalProperties: [AdditionalProperty(key: "imageUrl", value: placeItem.imageUrl!)], lat: placeItem.lat!.doubleValue, lon: placeItem.lon!.doubleValue)
        let image = place.downloadImage()
        let busyScore = ML.model.run(on: [image]).first!

        place.updateBusyScore(busyScore: busyScore)
        
        let entry = Entry(date: currentDate, place: place)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}
