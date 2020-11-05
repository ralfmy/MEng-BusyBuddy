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
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(store.places) { place in
                NavigationLink(destination: PlaceDetail(place: place).environmentObject(favourites)) {
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

struct AllPlacesView_Previews: PreviewProvider {
    @EnvironmentObject var store: PlacesDataManager
    @EnvironmentObject var favourites: Favourites
    @State static private var isShowingAll = false

    static var previews: some View {
        AllPlacesView(isPresented: $isShowingAll)
    }
}
