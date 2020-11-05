//
//  PlaceDetail.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct PlaceDetail: View {
    @EnvironmentObject var favourites: Favourites
    @State var buttonState = 0
    
    let place: Place
    
    var body: some View {
        VStack {
            Spacer()
            Button(buttonState == 0 ? "Add to Favourites" : "Remove from Favourites") {
                if favourites.contains(place: self.place) {
                    favourites.remove(place: self.place)
                    self.buttonState = 0
                } else {
                    favourites.add(place: self.place)
                    self.buttonState = 1
                }
            }.navigationBarTitle(self.place.commonName)
        }.onAppear {
            if favourites.contains(place: self.place) {
                self.buttonState = 1
            } else {
                self.buttonState = 0
            }
        }
    }
}

struct PlaceDetail_Previews: PreviewProvider {
    static var previews: some View {
        PlaceDetail(place: PlaceExample().place)
    }
}
