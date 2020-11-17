//
//  FavouritePlacesView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct FavouritePlacesView: View {
    @EnvironmentObject var favouritesManager: FavouritesManager
    
    @Binding var busyScores: [BusyScore]
    
    var body: some View {
        List(favouritesManager.getPlaces()) { place in
            NavigationLink(destination: FavouriteDetail(place: place, busyScores: $busyScores)) {
                PlaceRow(commonName: place.commonName)
            }
        }.listStyle(PlainListStyle())
    }
}

struct FavouritePlacesView_Previews: PreviewProvider {
    @State static private var busyScores = [BusyScore(id: "id", count: 5)]

    static var previews: some View {
        FavouritePlacesView(busyScores: $busyScores)
    }
}
