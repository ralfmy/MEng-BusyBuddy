//
//  BusyText.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 30/11/2020.
//

import SwiftUI

struct BusyText: View {
    @EnvironmentObject var bookmarksManager: BookmarksManager
    
    let busyScore: BusyScore
    
    var body: some View {
        Text(busyScore.scoreAsString())
            .font(.subheadline)
            .fontWeight(.bold)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .foregroundColor(setForegroundColour())
    }
    
    private func setForegroundColour() -> Color {
        switch busyScore.score {
        case .none:
            return Color.appGreyDarker
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
}

struct BusyText_Previews: PreviewProvider {
    static var previews: some View {
        BusyText(busyScore: BusyScore(id: ExamplePlace.place.id))
    }
}
