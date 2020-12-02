//
//  BusyIcon.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 30/11/2020.
//

import SwiftUI

struct BusyIcon: View {
    @EnvironmentObject var bookmarksManager: BookmarksManager
    
    let busyScore: BusyScore
    let size: CGFloat
    
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 100).fill(setBusyBackgroundColour()).frame(width: size, height: size)
            RoundedRectangle(cornerRadius: 100).fill(setBusyForegroundColour()).frame(width: 0.7 * size, height: 0.7 * size)
        }
    }
    
    private func setBusyForegroundColour() -> Color {
        switch busyScore.score {
        case .none:
            return Color.busyGreyBackground
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
    
    private func setBusyBackgroundColour() -> Color {
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
    
    private func setInnerSize() -> CGFloat {
        switch busyScore.score {
        case .none:
            return 0
        case .low:
            return 0.4 * size
        case .medium:
            return 0.6 * size
        case.high:
            return 0.8 * size
        default:
            return size
        }
    }
}

struct BusyIcon_Previews: PreviewProvider {
    static var previews: some View {
        BusyIcon(busyScore: BusyScore(id: ExamplePlace.place.id, count: 1), size: 75)
    }
}
