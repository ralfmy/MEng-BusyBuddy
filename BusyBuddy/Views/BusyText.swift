//
//  BusyText.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 30/11/2020.
//

import SwiftUI

struct BusyText: View {
    @EnvironmentObject private var placesManager: PlacesManager
    @EnvironmentObject private var bookmarksManager: BookmarksManager
    
    let id: String
    let font: Font
    
    var body: some View {
        Text(getBusyScore().scoreAsString())
            .font(font)
            .fontWeight(.bold)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .frame(alignment: .leading)
            .foregroundColor(getBusyScore().score == .none ? Color.appGreyDarker.opacity(0.8) : Color.white.opacity(0.8))
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
}

struct BusyText_Previews: PreviewProvider {
    static var previews: some View {
        BusyText(id: ExamplePlaces.oxfordCircus.id, font: .subheadline)
    }
}
