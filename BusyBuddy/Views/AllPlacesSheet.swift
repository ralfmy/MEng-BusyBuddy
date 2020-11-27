//
//  AllPlacesView.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import SwiftUI

struct AllPlacesSheet: View {
    @EnvironmentObject var placesManager: PlacesManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(placesManager.getPlaces()) { place in
                NavigationLink(destination: PlaceDetail(place: place)) {
                    PlaceRow(commonName: place.commonName)
                }
            }.listStyle(PlainListStyle())
            .navigationBarTitle("All Places", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.isPresented = false
            }) {
                Text("Done")
            })
        }
    }
}

struct AllPlacesSheet_Previews: PreviewProvider {
    @EnvironmentObject var store: PlacesDataManager
    @State static private var isShowingAll = false

    static var previews: some View {
        AllPlacesSheet(isPresented: $isShowingAll)
    }
}
