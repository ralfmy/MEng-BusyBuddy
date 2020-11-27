//
//  FavouritePlacesView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct FavouritePlacesView: View {
    @EnvironmentObject var favouritesManager: FavouritesManager
        
    var body: some View {
        List(favouritesManager.getPlaces()) { place in
            NavigationLink(destination: PlaceDetail(place: place)) {
                PlaceRow(commonName: place.commonName)
            }
        }.listStyle(PlainListStyle())
    }
}

struct FavouritePlacesView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritePlacesView()
    }
}
