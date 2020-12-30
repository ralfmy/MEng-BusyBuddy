//
//  BusyTimeline.swift
//  BusyWidgetsExtension
//
//  Created by Ralf Michael Yap on 30/12/2020.
//

import WidgetKit
import UIKit

struct BusyTimeline: TimelineProvider {
    typealias Entry = BusyEntry

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), place: ExamplePlaces.oxfordCircus)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let entry = Entry(date: Date(), place: ExamplePlaces.oxfordCircus)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        let place = ExamplePlaces.stGilesCircus
        

        let output = ML.model.run(on: [place]).first!

        let image = output.0
        let result = output.1
        if result.getObjectConfidences() != nil {
            let peopleCount = (result.objects.filter { $0.objClass == "person" && $0.confidence >= ML.model.threshold }).count
            print(peopleCount)
            place.updateBusyScore(busyScore: BusyScore(count: peopleCount, image: image))
        } else {
            place.updateBusyScore(busyScore: BusyScore(count: -2, image: image))
        }
        
        let entry = Entry(date: currentDate, place: place)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}
