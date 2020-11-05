//
//  PlaceDetail.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct PlaceDetail: View {
    @EnvironmentObject var favourites: Favourites
    
    let place: Place
    
    var body: some View {
        VStack {
            Spacer()
            Button("Add to Favourites") {
                favourites.add(place: self.place)
            }.navigationBarTitle(Text(self.place.commonName))
        }
    }
}

struct PlaceDetail_Previews: PreviewProvider {
    static var place = Place()
    init() {
        PlaceDetail_Previews.place.id = "JamCams_00001.07389"
        PlaceDetail_Previews.place.commonName = "University St/Gower St"
        PlaceDetail_Previews.place.placeType = "JamCam"
        PlaceDetail_Previews.place.imageUrl = "https://s3-eu-west-1.amazonaws.com/jamcams.tfl.gov.uk/00001.07389.jpg"
        PlaceDetail_Previews.place.lat = 51.5239
        PlaceDetail_Previews.place.lon = -0.1341
    }
    static var previews: some View {
        PlaceDetail(place: place)
    }
}
