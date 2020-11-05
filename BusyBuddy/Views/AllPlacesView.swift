//
//  AllPlacesView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct AllPlacesView: View {
    @EnvironmentObject var store: PlacesDataManager
    @EnvironmentObject var favourites: Favourites
    
    var body: some View {
        List(store.places) { place in
            NavigationLink(destination: PlaceDetail(place: place).environmentObject(favourites)) {
                PlaceRow(commonName: place.commonName)
            }
        }.listStyle(PlainListStyle())
    }
}

struct AllPlacesView_Previews: PreviewProvider {
    static var previews: some View {
        AllPlacesView()
    }
}
