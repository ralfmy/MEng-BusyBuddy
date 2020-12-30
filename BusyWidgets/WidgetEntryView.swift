//
//  WidgetEntryView.swift
//  BusyWidgetsExtension
//
//  Created by Ralf Michael Yap on 30/12/2020.
//

import SwiftUI

struct WidgetEntryView: View {
    let model: WidgetEntry
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct WidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(model: WidgetEntry(commonName: "Oxford Circus", imageUrl: "url", lat: 0.0, lon: 0.0, busyScore: BusyScore()))
    }
}
