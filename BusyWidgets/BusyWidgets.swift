//
//  BusyWidgets.swift
//  BusyWidgets
//
//  Created by Ralf Michael Yap on 27/12/2020.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct BusyWidgets: Widget {
    let kind: String = "com.zcabrmy.busy-widgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectJamCamIntent.self, provider: BusyTimeline()) { entry in
            BusyWidgetView(entry: entry)
        }
        .configurationDisplayName("BusyBuddy Widget")
        .description("Display the busyness for a bookmarked JamCam.")
    }
}

struct BusyWidgets_Previews: PreviewProvider {
    static var previews: some View {
        BusyWidgetView(entry: BusyEntry(date: Date(), jamCam: ExampleJamCams.oxfordCircus))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
