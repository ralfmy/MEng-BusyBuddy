//
//  BusyIcon.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 30/11/2020.
//

import SwiftUI

struct BusyIcon: View {
    @EnvironmentObject private var placesManager: PlacesManager
    @EnvironmentObject private var bookmarksManager: BookmarksManager
    
    let id: String
    let size: CGFloat
    let coloured: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle().fill(setBusyBackgroundColour()).frame(width: size, height: size)
            Circle().fill(setBusyForegroundColour()).frame(width: setInnerSize(), height: setInnerSize())
        }
    }
    
    private func getBusyScore() -> BusyScore {
        var busyScore: BusyScore
        if self.bookmarksManager.contains(id: self.id) {
            if let bs = self.bookmarksManager.getPlaceWith(id: self.id)!.busyScore {
                busyScore = bs
            } else {
                busyScore = BusyScore()
            }
        } else {
            if let bs = self.placesManager.getPlaceWith(id: self.id)!.busyScore {
                busyScore = bs
            } else {
                busyScore = BusyScore()
            }
        }
        
        return busyScore
    }
    
    private func setBusyForegroundColour() -> Color {
        let busyScore = getBusyScore()

        if coloured {
            switch busyScore.score {
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
        let busyScore = getBusyScore()
        
        if coloured {
            switch busyScore.score {
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
        let busyScore = getBusyScore()
        
        switch busyScore.score {
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

struct BusyIcon_Previews: PreviewProvider {
    static var previews: some View {
        BusyIcon(id: ExamplePlaces.oxfordCircus.id, size: 75, coloured: true)
    }
}
