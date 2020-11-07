//
//  FavouriteDetail.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct FavouriteDetail: View {
    @EnvironmentObject var favourites: Favourites
    @State var buttonState = 1
    @State var buttonColor = Color.red
    
    let place: Place
    
    var body: some View {
        VStack {
            Spacer()
            Button(buttonState == 0 ? "Add to Favourites" : "Remove from Favourites") {
                if favourites.contains(place: self.place) {
                    favourites.remove(place: self.place)
                    self.buttonState = 0
                    self.buttonColor = Color.blue
                } else {
                    favourites.add(place: self.place)
                    self.buttonState = 1
                    self.buttonColor = Color.red

                }
            }.foregroundColor(buttonColor)
            
            .navigationBarTitle(self.place.commonName)
            
        }.onAppear {
            if favourites.contains(place: self.place) {
                self.buttonState = 1
            } else {
                self.buttonState = 0
            }
        }
    }
}

struct FavouriteDetail_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteDetail(place: PlaceExample().place)
    }
}
