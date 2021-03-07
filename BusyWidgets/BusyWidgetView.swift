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
            BusyWidgetIcon(busyScore: entry.place.busyScore, size: 35, coloured: false)
            Spacer()
            CommonName
            Spacer().frame(height: 5)
            BusyWidgetText(busyScore: entry.place.busyScore, font: .footnote)
            LastUpdated
            Spacer().frame(height: 10)
        }
        .widgetURL(URL(string: "busybuddy://bookmarks/" + entry.place.id))
        .padding(15)
        .background(setCardColour())
    }
    
    private var CommonName: some View {
        Text(entry.place.commonNameText())
            .font(.callout)
            .fontWeight(.semibold)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .foregroundColor(setTextColour(opacity: 1))
    }
    
    private var LastUpdated: some View {
        Text(setLastUpdated())
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(setTextColour(opacity: 0.7))

    }
    
    private func setLastUpdated() -> String {
        if let busyScore = entry.place.busyScore {
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

struct BusyWidgetIcon: View {
    let busyScore: BusyScore?
    let size: CGFloat
    let coloured: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle().fill(setBusyBackgroundColour()).frame(width: size, height: size)
            Circle().fill(setBusyForegroundColour()).frame(width: setInnerSize(), height: setInnerSize())
        }
    }
    
    private func setBusyForegroundColour() -> Color {
        if coloured {
            switch self.busyScore?.score ?? BusyScore().score {
            case .none:
                return Color.busyGreyLighter
            case .low:
                return Color.busyGreenDarker
            case .medium:
                return Color.busyYellowDarker
            case.high:
                return Color.busyPinkDarker
            default:
                return Color.white
            }
        } else {
            return Color.white.opacity(0.4)
        }
        
    }
    
    private func setBusyBackgroundColour() -> Color {
        if coloured {
            switch self.busyScore?.score ?? BusyScore().score {
            case .none:
                return Color.busyGreyLighter
            case .low:
                return Color.busyGreenLighter
            case .medium:
                return Color.busyYellowLighter
            case.high:
                return Color.busyPinkLighter
            default:
                return Color.white
            }
        } else {
            return Color.white.opacity(0.4)
        }
    }
    
    private func setInnerSize() -> CGFloat {
        switch self.busyScore?.score ?? BusyScore().score {
        case .none:
            return 0
        case .low:
            return 0.5 * size
        case .medium:
            return 0.6 * size
        case .high:
            return 0.8 * size
        case .unsure:
            return 0
        default:
            return size
        }
    }
}

struct BusyWidgetText: View {
    let busyScore: BusyScore?
    let font: Font
    
    var body: some View {
        Text(busyScore?.scoreAsString() ?? "")
            .font(font)
            .fontWeight(.bold)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .frame(alignment: .leading)
            .foregroundColor(busyScore?.score ?? BusyScore().score == .none ? Color.appGreyDarker.opacity(0.8) : Color.white.opacity(0.8))
    }
}

struct BusyWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        BusyWidgetView(entry: BusyEntry(date: Date(), place: ExamplePlaces.oxfordCircus))
    }
}
