//
//  PlaceDetail.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct PlaceDetail: View {
    @EnvironmentObject var favouritesManager: FavouritesManager
    @State var buttonState = 0
    
    let place: CodablePlace
    
    var body: some View {
        VStack {
            Spacer()
            Button(buttonState == 0 ? "Add to Favourites" : "Remove from Favourites") {
                if favouritesManager.contains(place: self.place) {
                    favouritesManager.remove(place: self.place)
                    self.buttonState = 0
                } else {
                    favouritesManager.add(place: self.place)
                    self.buttonState = 1
                }
            }.navigationBarTitle(self.place.commonName)
        }.onAppear {
            if favouritesManager.contains(place: self.place) {
                self.buttonState = 1
            } else {
                self.buttonState = 0
            }
        }
    }
}

struct PlaceDetail_Previews: PreviewProvider {
    static var previews: some View {
        PlaceDetail(place: PlaceExample.place)
    }
}
