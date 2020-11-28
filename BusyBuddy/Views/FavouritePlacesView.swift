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
        PlacesList(places: favouritesManager.getPlaces())
    }
}

struct FavouritePlacesView_Previews: PreviewProvider {
    static var previews: some View {
        FavouritePlacesView()
    }
}
