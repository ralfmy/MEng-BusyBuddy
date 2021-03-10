//
//  BusyWidgetView.swift
//  BusyWidgetsExtension
//
//  Created by Ralf Michael Yap on 30/12/2020.
//

import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        Text("Loading...")
    }
}

struct BusyWidgetView: View {
    let entry: BusyEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 10)
            BusyIcon(busyScore: self.entry.place.busyScore ?? BusyScore(), size: 35, coloured: false)
            Spacer()
            CommonName
            Spacer().frame(height: 5)
            BusyText(busyScore: self.entry.place.busyScore ?? BusyScore(), font: .footnote)
            LastUpdated
            Spacer().frame(height: 10)
        }
        .widgetURL(URL(string: "busybuddy://bookmarks/" + entry.place.id))
        .padding(15)
        .background(setCardColour())
    }
    
    private var CommonName: some View {
        Text(self.entry.place.commonNameAsText())
            .font(.callout)
            .fontWeight(.semibold)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .foregroundColor(setTextColour(opacity: 1))
    }
    
    private var LastUpdated: some View {
        Text(self.setLastUpdated())
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(setTextColour(opacity: 0.7))

    }
    
    private func setLastUpdated() -> String {
        if let busyScore = self.entry.place.busyScore {
            return "Updated: " + busyScore.dateAsString()
        } else {
            return ""
        }
    }
    
    private func setTextColour(opacity: Double) -> Color {
        if let busyScore = entry.place.busyScore {
            switch busyScore.score {
            case .none:
                return Color.appGreyDarkest.opacity(0.8)
            default:
                return Color.white.opacity(opacity)
            }
        } else {
            return Color.appGreyDarkest.opacity(0.8)
        }
    }

    private func setCardColour() -> Color {
        if let busyScore = entry.place.busyScore {
            switch busyScore.score {
            case .none:
                return Color.busyYellowDarker
            case .low:
                return Color.busyGreenDarker
            case .medium:
                return Color.busyYellowDarker
            case .high:
                return Color.busyPinkDarker
            case .unsure:
                return Color.busyYellowDarker
            }
        } else {
            return Color.busyGreyLighter
        }
    }
}

struct BusyWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        BusyWidgetView(entry: BusyEntry(date: Date(), place: ExamplePlaces.oxfordCircus))
    }
}
