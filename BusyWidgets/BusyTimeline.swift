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

        let busyScore = ML.model.generateBusyScore(from: output)
        place.updateBusyScore(busyScore: busyScore)
        
        let entry = Entry(date: currentDate, place: place)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}
