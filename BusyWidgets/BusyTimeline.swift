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
    typealias Intent = SelectJamCamIntent

    func placeholder(in context: Context) -> Entry {
        var jamCam = ExampleJamCams.oxfordCircus
        jamCam.updateBusyScore(busyScore: BusyScore())
        let image = jamCam.downloadImage()
        let busyScore = ML.currentModel().run(on: [image]).first!
        jamCam.updateBusyScore(busyScore: busyScore)
        return Entry(date: Date(), jamCam: jamCam)
    }
    
    func getSnapshot(for configuration: Intent, in context: Context, completion: @escaping (Entry) -> Void) {
        let jamCam = ExampleJamCams.gowerSt
        jamCam.updateBusyScore(busyScore: BusyScore(count: 1))
        let entry = Entry(date: Date(), jamCam: jamCam)
        completion(entry)
    }
    
    func getTimeline(for configuration: Intent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        
        guard let jamCamItem = configuration.jamCam else {
            let entry = Entry(date: currentDate, jamCam: ExampleJamCams.oxfordCircus)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
            return
        }
        
        let jamCam = JamCam(id: jamCamItem.identifier!, commonName: jamCamItem.displayString, placeType: jamCamItem.placeType!, additionalProperties: [AdditionalProperty(key: "imageUrl", value: jamCamItem.imageUrl!)], lat: jamCamItem.lat!.doubleValue, lon: jamCamItem.lon!.doubleValue)
        let image = jamCam.downloadImage()
        let busyScore = ML.currentModel().run(on: [image]).first!

        jamCam.updateBusyScore(busyScore: busyScore)
        
        let entry = Entry(date: currentDate, jamCam: jamCam)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}
