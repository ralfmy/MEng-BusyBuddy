//
//  BusyIcon.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 30/11/2020.
//

import SwiftUI

struct BusyIcon: View {
    @EnvironmentObject var favouritesManager: FavouritesManager
    
    let busyScore: BusyScore
    let size: CGFloat
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle().fill(setBusyBackgroundColour(busyScore: busyScore)).frame(width: size, height: size)
            RoundedRectangle(cornerRadius: 15).fill(setBusyForegroundColour(busyScore: busyScore)).frame(width: size / 2, height: size / 2)
        }
    }
    
    private func setBusyForegroundColour(busyScore: BusyScore) -> Color {
        switch busyScore.score {
        case .none:
            return Color.busyGreyForeground
        case .low:
            return Color.busyGreenForeground
        case .medium:
            return Color.busyYellowForeground
        case.high:
            return Color.busyPinkForeground
        default:
            return Color.white
        }
    }
    
    private func setBusyBackgroundColour(busyScore: BusyScore) -> Color {
        switch busyScore.score {
        case .none:
            return Color.busyGreyBackground
        case .low:
            return Color.busyGreenBackground
        case .medium:
            return Color.busyYellowBackground
        case.high:
            return Color.busyPinkBackground
        default:
            return Color.white
        }
    }
}

struct BusyIcon_Previews: PreviewProvider {
    static var previews: some View {
        BusyIcon(busyScore: BusyScore(id: ExamplePlace.place.id, count: 7), size: 75)
    }
}
