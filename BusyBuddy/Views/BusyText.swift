//
//  BusyText.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 30/11/2020.
//

import SwiftUI

struct BusyText: View {
    @EnvironmentObject var favouritesManager: FavouritesManager
    
    let id: String
    
    var body: some View {
        Text(favouritesManager.getScoreFor(id: id)!.scoreAsString()).font(.subheadline).fontWeight(.bold).foregroundColor(setForegroundColour(id: id))
    }
    
    private func setForegroundColour(id: String) -> Color {
        let busyScore = favouritesManager.getScoreFor(id: id)!
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
}

struct BusyText_Previews: PreviewProvider {
    static var previews: some View {
        BusyText(id: ExamplePlace.place.id)
    }
}
