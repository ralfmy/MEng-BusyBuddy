//
//  FavouritePlacesView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct FavouritePlacesView: View {
    @EnvironmentObject var store: PlacesDataManager
    @EnvironmentObject var favourites: Favourites
    
    var places: [Place]
    
    var body: some View {
        List(places) { place in
            NavigationLink(destination: FavouriteDetail(place: place)) {
                PlaceRow(commonName: place.commonName)
            }
        }.listStyle(PlainListStyle())
    }
}

struct FavouritePlacesView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritePlacesView(places: [Place]())
    }
}
